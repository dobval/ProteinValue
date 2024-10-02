import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'foodItems.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE foodItems(name TEXT PRIMARY KEY,'
              ' price DOUBLE,'
              ' protein100g INT,'
              ' kcal100g INT,'
              ' grams INT)',
        );
      },
    );
  }

  Future<void> insertFoodItem(FoodItem foodItem) async {
    final db = await database;
    await db.insert(
      'foodItems',
      foodItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FoodItem>> getFoodItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('foodItems');

    return List.generate(maps.length, (i) {
      return FoodItem.fromMap(maps[i]);
    });
  }

  Future<void> deleteFoodItem(String name) async {
    final db = await database;
    await db.delete(
      'foodItems',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<void> updateFoodItem(FoodItem foodItem) async {
    final db = await database;
    await db.update(
      'foodItems',
      foodItem.toMap(),
      where: 'name = ?',
      whereArgs: [foodItem.name],
    );
  }
}
