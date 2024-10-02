import '../models/food_item.dart';
import 'db_helper.dart';

class DBController {

  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> addFoodItem(FoodItem foodItem) async {
    await dbHelper.insertFoodItem(foodItem);
  }

  Future<List<FoodItem>> fetchFoodItems() async {
    return await dbHelper.getFoodItems();
  }

  Future<void> removeFoodItem(String name) async {
    await dbHelper.deleteFoodItem(name);
  }

  Future<void> modifyFoodItem(FoodItem foodItem) async {
    await dbHelper.updateFoodItem(foodItem);
  }
  /*
  List<FoodItem> _foodItems = [];

  List<FoodItem> get foodItems => _foodItems;

  void addFoodItem(String name, double price, int protein100g, int kcal100g,
      int grams) {
    final newFoodItem = FoodItem(
      name: name,
      price: price,
      protein100g: protein100g,
      kcal100g: kcal100g,
      grams: grams,
    );
    _foodItems.add(newFoodItem);
  }
   */
}