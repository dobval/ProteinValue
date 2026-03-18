import 'package:flutter/material.dart';
import 'package:proteinvalue/controllers/db_helper.dart';
import 'package:provider/provider.dart';
import 'models/food_item.dart';
import 'models/rankings.dart';
import 'views/folder.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
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
        home: const AppHomePage(
          title: 'Home Page',
        ),
      );
    });
  }
}

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key, required this.title});

  final String title;

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  static const int kTopItemsCount = 10;
  static const double kRatioScale = 100.0;

  final DBController _controller = DBController();
  List<FoodItem> _foodItems = [];

  int _selectedIndex = 0;
  Rankings _selectedRanking = Rankings.cheapProteinRich;

  late _SortBy _sortBy;
  late bool _isAscending;

  @override
  void initState() {
    super.initState();
    _sortBy = _SortBy.name;
    _isAscending = true;
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    _foodItems = await _controller.fetchFoodItems();
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
          ],
        ),
      ),
      body: _selectedIndex == 0
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

  Widget _buildFoodItemList() {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverHeaderDelegate(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: _buildHeaderCell('Name', _SortBy.name)),
                        Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Price', _SortBy.price)),
                        Expanded(
                            flex: 1,
                            child: _buildHeaderCell(
                                'Protein/100g', _SortBy.protein)),
                        Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Kcal/100g', _SortBy.kcal)),
                        Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Grams', _SortBy.grams)),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final foodItem = _foodItems[index];
              return Container(
                color: Theme.of(context).colorScheme.surface,
                child: GestureDetector(
                  onLongPress: () => _showDeleteConfirmationDialog(foodItem),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(foodItem.name, softWrap: true)),
                        Expanded(
                            flex: 1,
                            child: Text('${foodItem.price}', softWrap: true)),
                        Expanded(
                            flex: 1,
                            child: Text('${foodItem.protein100g}',
                                softWrap: true)),
                        Expanded(
                            flex: 1,
                            child:
                                Text('${foodItem.kcal100g}', softWrap: true)),
                        Expanded(
                            flex: 1,
                            child: Text('${foodItem.grams}', softWrap: true)),
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
    switch (_selectedRanking) {
      case Rankings.cheapProteinRich:
        return item.price > 0
            ? (item.protein100g * item.grams) / (item.price * kRatioScale)
            : 0;
      case Rankings.leanProteinRich:
        return item.kcal100g > 0 ? item.protein100g / item.kcal100g : 0;
      case Rankings.cheapLeanProteinRich:
        return (item.price > 0 && item.kcal100g > 0)
            ? (item.protein100g * item.grams) /
                (item.price * kRatioScale * item.kcal100g)
            : 0;
      case Rankings.cheapHighCalorie:
        return item.price > 0
            ? (item.kcal100g * item.grams) / (item.price * kRatioScale)
            : 0;
    }
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
        return AddFoodDialog(controller: _controller);
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
    await _controller.removeFoodItem(foodItem.name);
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

  Widget _buildHeaderCell(String title, _SortBy sortBy) {
    return GestureDetector(
      onTap: () => _onHeaderTap(sortBy),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Flexible(
          fit: FlexFit.tight,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
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
      ),
    );
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
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _SliverHeaderDelegate({required this.child});

  @override
  double get minExtent => 60.0;

  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

enum _SortBy {
  name,
  price,
  protein,
  kcal,
  grams,
}
