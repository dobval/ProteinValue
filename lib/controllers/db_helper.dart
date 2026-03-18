import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_item.dart';

class DBController {
  static final DBController _instance = DBController._internal();
  factory DBController() => _instance;
  static Database? _database;

  DBController._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final String path = join(await getDatabasesPath(), FoodItem.kDatabaseName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE ${FoodItem.kTableName}('
          '${FoodItem.kColName} TEXT PRIMARY KEY,'
          '${FoodItem.kColPrice} DOUBLE,'
          '${FoodItem.kColProtein} INT,'
          '${FoodItem.kColKcal} INT,'
          '${FoodItem.kColGrams} INT)',
        );
      },
    );
  }

  Future<void> addFoodItem(FoodItem foodItem) async {
    final db = await database;
    await db.insert(
      FoodItem.kTableName,
      foodItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FoodItem>> fetchFoodItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(FoodItem.kTableName);
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  Future<void> removeFoodItem(String name) async {
    final db = await database;
    await db.delete(
      FoodItem.kTableName,
      where: '${FoodItem.kColName} = ?',
      whereArgs: [name],
    );
  }

  Future<void> modifyFoodItem(FoodItem foodItem) async {
    final db = await database;
    await db.update(
      FoodItem.kTableName,
      foodItem.toMap(),
      where: '${FoodItem.kColName} = ?',
      whereArgs: [foodItem.name],
    );
  }
}
