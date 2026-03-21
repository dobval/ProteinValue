import 'package:flutter/material.dart';
import 'package:proteinvalue/controllers/db_controller.dart';
import 'package:proteinvalue/models/food_item.dart';
import 'package:proteinvalue/models/rankings.dart';
import 'package:proteinvalue/utils/ranking_calculator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/folder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final colorIndex = prefs.getInt(ThemeNotifier.kColorIndexKey) ?? 0;
  final themeNotifier = ThemeNotifier(colorIndex);

  final controller = DBController();
  await controller.migrateIfNeeded();

  runApp(
    ChangeNotifierProvider<ThemeNotifier>.value(
      value: themeNotifier,
      child: const ProteinValueApp(),
    ),
  );
}

class ProteinValueApp extends StatefulWidget {
  const ProteinValueApp({super.key});

  @override
  State<ProteinValueApp> createState() => _ProteinValueAppState();
}

class _ProteinValueAppState extends State<ProteinValueApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, themeNotifier, child) {
      return MaterialApp(
        title: 'Protein Value Flutter',
        theme: themeNotifier.currentTheme,
        themeMode: ThemeMode.system,
        home: const AppHomePage(),
      );
    });
  }
}

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  static const int kTopItemsCount = 10;

  final DBController _controller = DBController();
  List<FoodItem> _foodItems = [];

  int _selectedIndex = 0;
  Rankings _selectedRanking = Rankings.cheapProteinRich;

  late _SortBy _sortBy;
  late bool _isAscending;

  List<Region> _regions = [];
  Region? _activeRegion;

  @override
  void initState() {
    super.initState();
    _sortBy = _SortBy.name;
    _isAscending = true;
    _loadData();
  }

  Future<void> _loadData() async {
    _regions = await _controller.getAllRegions();
    _activeRegion = await _controller.getActiveRegion();
    await _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    if (_activeRegion == null) return;
    _foodItems = await _controller.fetchFoodItems(
        regionSanitized: _activeRegion!.sanitizedName);
    _sortFoodItems();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(_selectedIndex == 0 ? 'Food List' : 'Rankings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).changeColor();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: ColoredBox(
        color: Colors.white,
        child: _selectedIndex == 0
            ? _buildFoodItemList()
            : Column(
                children: [
                  DropdownButton<Rankings>(
                    value: _selectedRanking,
                    items: Rankings.values.map((ranking) {
                      return DropdownMenuItem(
                        value: ranking,
                        child: Center(child: Text(ranking.displayName)),
                      );
                    }).toList(),
                    onChanged: (Rankings? newValue) {
                      setState(() {
                        _selectedRanking = newValue!;
                      });
                    },
                    isExpanded: true,
                  ),
                  Expanded(
                    child: _buildRankingView(),
                  ),
                ],
              ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddFoodDialog(context),
              tooltip: 'Add Food',
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Ranking Formula'),
                      content: Text(_selectedRanking.explanation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Text('Menu'),
          ),
          ListTile(
            title: const Text('Food List'),
            onTap: () {
              if (_selectedIndex != 0) {
                setState(() {
                  _selectedIndex = 0;
                });
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Rankings'),
            onTap: () {
              if (_selectedIndex != 1) {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Region',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButton<Region>(
              value: _regions.isEmpty
                  ? null
                  : _regions.firstWhere(
                      (r) => r.sanitizedName == _activeRegion?.sanitizedName,
                      orElse: () => _regions.first,
                    ),
              isExpanded: true,
              underline: const SizedBox(),
              items: _regions.map((region) {
                return DropdownMenuItem(
                  value: region,
                  child: Text(region.displayName),
                );
              }).toList(),
              onChanged: (Region? newRegion) {
                if (newRegion != null) {
                  _onRegionChanged(newRegion);
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create Region'),
            onTap: () {
              Navigator.pop(context);
              _showCreateRegionDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename Region'),
            onTap: () {
              Navigator.pop(context);
              _showRenameRegionDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Region'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteRegionDialog();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Region'),
            onTap: () {
              Navigator.pop(context);
              _showImportDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export Region'),
            onTap: () {
              Navigator.pop(context);
              _showExportRegionDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onRegionChanged(Region region) async {
    await _controller.setActiveRegion(region.sanitizedName);
    _activeRegion = region;
    await _loadFoodItems();
  }

  Widget _buildFoodItemList() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _FoodListHeaderDelegate(_buildFoodListHeader),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final foodItem = _foodItems[index];
              return GestureDetector(
                onTap: () => _showEditFoodDialog(context, foodItem),
                onLongPress: () => _showDeleteConfirmationDialog(foodItem),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(foodItem.name,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis)),
                        Expanded(
                            flex: 1,
                            child: Text('${foodItem.price}',
                                softWrap: true,
                                overflow: TextOverflow.ellipsis)),
                        Expanded(
                            flex: 1,
                            child: Text('${foodItem.protein100g}',
                                softWrap: true,
                                overflow: TextOverflow.ellipsis)),
                        Expanded(
                            flex: 1,
                            child: Text('${foodItem.kcal100g}',
                                softWrap: true,
                                overflow: TextOverflow.ellipsis)),
                        Expanded(
                            flex: 1,
                            child: Text('${foodItem.grams}',
                                softWrap: true,
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),
              );
            },
            childCount: _foodItems.length,
          ),
        ),
      ],
    );
  }

  List<FoodItem> _getRankedItems() {
    final sortedItems = List<FoodItem>.from(_foodItems);
    sortedItems.sort((a, b) {
      final ratioA = _calculateRankRatio(a);
      final ratioB = _calculateRankRatio(b);
      return ratioB.compareTo(ratioA);
    });
    return sortedItems.take(kTopItemsCount).toList();
  }

  double _calculateRankRatio(FoodItem item) {
    return RankingCalculator.calculate(item, _selectedRanking);
  }

  Widget _buildRankingView() {
    final topItems = _getRankedItems();

    return ListView.builder(
      itemCount: topItems.length,
      itemBuilder: (context, index) {
        final item = topItems[index];
        final ratio = _calculateRankRatio(item);

        return ListTile(
          title: Text('${index + 1}. ${item.name}'),
          subtitle:
              Text('${_selectedRanking.formula}: ${ratio.toStringAsFixed(2)}'),
        );
      },
    );
  }

  void _showAddFoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FoodDialog(
          onSave: (item) async {
            await _controller.addFoodItem(item);
          },
        );
      },
    ).then((result) {
      if (result == true) {
        _loadFoodItems();
      }
    });
  }

  void _showEditFoodDialog(BuildContext context, FoodItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FoodDialog(
          initialItem: item,
          onSave: (updatedItem) async {
            await _controller.modifyFoodItem(updatedItem);
          },
        );
      },
    ).then((result) {
      if (result == true) {
        _loadFoodItems();
      }
    });
  }

  void _showDeleteConfirmationDialog(FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${foodItem.name}?'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteFoodItem(foodItem);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFoodItem(FoodItem foodItem) async {
    await _controller.removeFoodItem(foodItem.name,
        regionSanitized: _activeRegion?.sanitizedName);
    await _loadFoodItems();
  }

  void _sortFoodItems() {
    _foodItems.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case _SortBy.name:
          comparison = a.name.compareTo(b.name);
        case _SortBy.price:
          comparison = a.price.compareTo(b.price);
        case _SortBy.protein:
          comparison = a.protein100g.compareTo(b.protein100g);
        case _SortBy.kcal:
          comparison = a.kcal100g.compareTo(b.kcal100g);
        case _SortBy.grams:
          comparison = a.grams.compareTo(b.grams);
      }
      return _isAscending ? comparison : -comparison;
    });
  }

  void _onHeaderTap(_SortBy sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _isAscending = !_isAscending;
      } else {
        _sortBy = sortBy;
        _isAscending = true;
      }
      _sortFoodItems();
    });
  }

  Widget _buildHeaderCell(String title, _SortBy sortBy) {
    return GestureDetector(
      onTap: () => _onHeaderTap(sortBy),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (_sortBy == sortBy)
              Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateRegionDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Create Region'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Region name',
              hintText: 'e.g. Berlin',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = textController.text.trim();
                if (name.isEmpty) {
                  _showSnackBar('Region name cannot be empty');
                  return;
                }
                try {
                  final exists = _regions.any(
                      (r) => r.displayName.toLowerCase() == name.toLowerCase());
                  if (exists) {
                    _showSnackBar('Region already exists');
                    return;
                  }
                  final region = await _controller.createRegion(name);
                  await _controller.setActiveRegion(region.sanitizedName);
                  await _loadData();
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  _showSnackBar(e.toString());
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameRegionDialog() {
    if (_activeRegion == null) return;
    final textController =
        TextEditingController(text: _activeRegion!.displayName);
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Rename Region'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'New name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = textController.text.trim();
                if (name.isEmpty) {
                  _showSnackBar('Region name cannot be empty');
                  return;
                }
                try {
                  final exists = _regions.any((r) =>
                      r.displayName.toLowerCase() == name.toLowerCase() &&
                      r.sanitizedName != _activeRegion!.sanitizedName);
                  if (exists) {
                    _showSnackBar('Region already exists');
                    return;
                  }
                  await _controller.renameRegion(
                      _activeRegion!.displayName, name);
                  await _loadData();
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  _showSnackBar(e.toString());
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteRegionDialog() {
    if (_activeRegion == null) return;
    final sanitized = _activeRegion!.sanitizedName;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Region?'),
          content: FutureBuilder<int>(
            future: _controller.getRegionFoodCount(sanitized),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Text(
                'This will permanently delete all $count food items '
                'in "${_activeRegion!.displayName}".',
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showDeleteRegionSecondConfirmation(sanitized, ctx);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteRegionSecondConfirmation(String sanitized, BuildContext ctx) {
    showDialog(
      context: context,
      builder: (BuildContext innerCtx) {
        return Transform.translate(
          offset: const Offset(0, 100),
          child: AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(innerCtx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  try {
                    await _controller.deleteRegion(sanitized);
                    await _loadData();
                    if (innerCtx.mounted) Navigator.of(innerCtx).pop();
                    _showSnackBar('Region deleted');
                  } catch (e) {
                    _showSnackBar(e.toString());
                  }
                },
                child: const Text('Delete Forever'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExportRegionDialog() async {
    if (_activeRegion == null) return;
    final region = _activeRegion!;
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final fileName = 'proteinvalue_${region.sanitizedName}_$timestamp.sql';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    ).then((_) {});

    try {
      final sql = await _controller.exportRegionSQL(region.sanitizedName);
      if (!mounted) return;
      Navigator.of(context).pop();
      await _controller.exportAndShare(sql, fileName);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnackBar('Export failed: $e');
    }
  }

  void _showImportDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    ).then((_) {});

    try {
      final result = await _controller.pickAndImportSQL();
      if (!mounted) return;
      Navigator.of(context).pop();
      if (result != null) {
        await _loadData();
        _showSnackBar('Imported region: ${result.displayName}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showImportErrorDialog(e.toString());
    }
  }

  void _showImportErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Import Failed'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildFoodListHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: 2, child: _buildHeaderCell('Name', _SortBy.name)),
              Expanded(
                  flex: 1, child: _buildHeaderCell('Price', _SortBy.price)),
              Expanded(
                  flex: 1,
                  child: _buildHeaderCell('Protein/100g', _SortBy.protein)),
              Expanded(
                  flex: 1, child: _buildHeaderCell('Kcal/100g', _SortBy.kcal)),
              Expanded(
                  flex: 1, child: _buildHeaderCell('Grams', _SortBy.grams)),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class _FoodListHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(BuildContext) builder;

  _FoodListHeaderDelegate(this.builder);

  @override
  double get minExtent => 60.0;

  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context);
  }

  @override
  bool shouldRebuild(covariant _FoodListHeaderDelegate oldDelegate) => true;
}

enum _SortBy {
  name,
  price,
  protein,
  kcal,
  grams,
}
