import 'package:flutter/material.dart';
import 'package:proteinvalue/controllers/db_controller.dart';
import 'package:provider/provider.dart';
import 'models/food_item.dart';
import 'views/folder.dart';

//TODO: Organize all views separately into views/ !
//TODO: Add multiple currencies, option to switch
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: ProteinValueApp(),
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
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Protein Value Flutter',
          theme: themeNotifier.currentTheme,
          themeMode: ThemeMode.system,
          home: AppHomePage(
            title: 'Home Page',
          ),
        );
      }
    );
  }
}

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key, required this.title});

  final String title;

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  final DBController _controller = DBController();
  List<FoodItem> _foodItems = [];

  int _selectedIndex = 0; // Drawer selected view
  String _selectedRanking = 'Cheap Protein-Rich';
  String _rankingExplanation = '';

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
    _updateRankingExplanation();
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
                    _selectedIndex = 0; // Updates index
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
                  Navigator.pop(context); // Close the drawer after switching
                  // Add navigation logic here for Rankings if needed
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
                DropdownButton<String>(
                  value: _selectedRanking,
                  items: const [
                    DropdownMenuItem(
                        value: 'Cheap Protein-Rich',
                        child: Center(child: Text('Cheap Protein-Rich'))),
                    DropdownMenuItem(
                        value: 'Lean Protein-Rich',
                        child: Center(child: Text('Lean Protein-Rich'))),
                    DropdownMenuItem(
                        value: 'Cheap Lean Protein-Rich',
                        child: Center(child: Text('Cheap Lean Protein-Rich'))),
                    DropdownMenuItem(
                        value: 'Cheap High-Calorie',
                        child: Center(child: Text('Cheap High-Calorie'))),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRanking = newValue!;
                      _updateRankingExplanation();
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
                      content: Text(_rankingExplanation),
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
            ), // No FAB on Rankings
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
                // 5 pixels padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column headers with sorting functionality
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: _buildHeaderCell('Name', SortBy.name)),
                        Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Price', SortBy.price)),
                        Expanded(
                            flex: 1,
                            child: _buildHeaderCell(
                                'Protein/100g', SortBy.protein)),
                        Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Kcal/100g', SortBy.kcal)),
                        Expanded(
                            flex: 1,
                            child: _buildHeaderCell('Grams', SortBy.grams)),
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
                    // 5 pixels padding
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

  List<FoodItem> _getTop10ItemsByProteinPriceRatio() {
    List<FoodItem> sortedItems = List.from(_foodItems);
    sortedItems.sort((a, b) {
      double ratioA =
          a.price > 0 ? (a.protein100g * a.grams) / (a.price*100) : 0;
      double ratioB =
          b.price > 0 ? (b.protein100g * b.grams) / (b.price*100) : 0;
      return ratioB.compareTo(ratioA); // Descending order
    });

    return sortedItems.take(10).toList();
  }

  List<FoodItem> _getTop10ItemsByProteinKcalRatio() {
    List<FoodItem> sortedItems = List.from(_foodItems);
    sortedItems.sort((a, b) {
      double ratioA =
      a.price > 0 ? (a.protein100g) / a.kcal100g : 0;
      double ratioB =
      b.price > 0 ? (b.protein100g) / b.kcal100g : 0;
      return ratioB.compareTo(ratioA); // Descending order
    });

    return sortedItems.take(10).toList();
  }

  List<FoodItem> _getTop10ItemsByProteinPriceKcalRatio() {
    List<FoodItem> sortedItems = List.from(_foodItems);
    sortedItems.sort((a, b) {
      double ratioA =
      a.price > 0 ? (a.protein100g * a.grams) / (a.price*100*a.kcal100g) : 0;
      double ratioB =
      b.price > 0 ? (b.protein100g * b.grams) / (b.price*100*b.kcal100g) : 0;
      return ratioB.compareTo(ratioA); // Descending order
    });

    return sortedItems.take(10).toList();
  }

  List<FoodItem> _getTop10ItemsByKcalPriceRatio() {
    List<FoodItem> sortedItems = List.from(_foodItems);
    sortedItems.sort((a, b) {
      double ratioA =
      a.price > 0 ? (a.kcal100g * a.grams) / (a.price * 100) : 0;
      double ratioB =
      b.price > 0 ? (b.kcal100g * b.grams) / (b.price * 100) : 0;
      return ratioB.compareTo(ratioA); // Descending order
    });

    return sortedItems.take(10).toList();
  }

  Widget _buildRankingView() {
    List<FoodItem> top10Items;

    switch (_selectedRanking) {
      case 'Cheap Protein-Rich':
        top10Items = _getTop10ItemsByProteinPriceRatio();
        break;
      case 'Lean Protein-Rich':
        top10Items = _getTop10ItemsByProteinKcalRatio();
        break;
      case 'Cheap Lean Protein-Rich':
        top10Items = _getTop10ItemsByProteinPriceKcalRatio();
        break;
      case 'Cheap High-Calorie':
        top10Items = _getTop10ItemsByKcalPriceRatio();
        break;
      default:
        top10Items = _getTop10ItemsByProteinPriceRatio(); // default to 'Cheap Protein-Rich'
    }

    return ListView.builder(
      itemCount: top10Items.length,
      itemBuilder: (context, index) {
        final item = top10Items[index];
        double ratio;

        switch (_selectedRanking) {
          case 'Cheap Protein-Rich':
            ratio = item.price > 0
                ? (item.protein100g * item.grams) / (item.price*100)
                : 0;
            break;
          case 'Lean Protein-Rich':
            ratio = item.kcal100g > 0
                ? (item.protein100g) / item.kcal100g
                : 0;
            break;
          case 'Cheap Lean Protein-Rich':
            ratio = (item.price > 0 && item.kcal100g > 0)
                ? (item.protein100g * item.grams) / (item.price*100*item.kcal100g)
                : 0;
            break;
          case 'Cheap High-Calorie':
            ratio = item.price > 0
                ? (item.kcal100g * item.grams) / (item.price * 100)
                : 0;
            break;
          default:
            ratio = 0;
        }

        return ListTile(
          title: Text('${index + 1}. ${item.name}'),
          subtitle: Text('$_selectedRanking: ${ratio.toStringAsFixed(2)}'),
        );
      },
    );
  }

  void _updateRankingExplanation() {
    switch (_selectedRanking) {
      case 'Cheap Protein-Rich':
        _rankingExplanation = 'Calculated as Protein/Price. Example: (11*5)/1,49 = 36,92g for 1€ (ja! Skyr Natur 500g 1,49€; 11g Protein per 100g).';
        break;
      case 'Lean Protein-Rich':
        _rankingExplanation = 'Calculated as Protein/Kcal. Example: Chicken Breast';
        break;
      case 'Cheap Lean Protein-Rich':
        _rankingExplanation = 'Calculated as (Protein/Price)/Kcal. Example: Low-fat Cheese';
        break;
      case 'Cheap High-Calorie':
        _rankingExplanation = 'Calculated as Kcal/Price. Examples: Flour, Oil';
        break;
      default:
        _rankingExplanation = 'Select a ranking to see the formula.';
    }
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
        case SortBy.name:
          comparison = a.name.compareTo(b.name);
          break;
        case SortBy.price:
          comparison = a.price.compareTo(b.price);
          break;
        case SortBy.protein:
          comparison = a.protein100g.compareTo(b.protein100g);
          break;
        case SortBy.kcal:
          comparison = a.kcal100g.compareTo(b.kcal100g);
          break;
        case SortBy.grams:
          comparison = a.grams.compareTo(b.grams);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });
  }

  Widget _buildHeaderCell(String title, SortBy sortBy) {
    return GestureDetector(
      onTap: () => _onHeaderTap(sortBy),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Flexible(
          fit: FlexFit.tight, // Ensure it takes up available space
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
              if (_sortBy ==
                  sortBy) // Show sort indicator if this column is being sorted
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

  void _onHeaderTap(SortBy sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _isAscending =
            !_isAscending; // Toggle sort order if the same header is tapped
      } else {
        _sortBy = sortBy;
        _isAscending = true; // Default to ascending on new sort field
      }
      _sortFoodItems(); // Sort the list
    });
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverHeaderDelegate({required this.child});

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

enum SortBy {
  name,
  price,
  protein,
  kcal,
  grams,
}

SortBy _sortBy = SortBy.name;
bool _isAscending = true;
