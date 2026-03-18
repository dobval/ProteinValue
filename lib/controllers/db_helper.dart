import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';
import '../models/food_item.dart';

class Region {
  final String displayName;
  final String sanitizedName;

  const Region({required this.displayName, required this.sanitizedName});
}

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
    final String path =
        p.join(await getDatabasesPath(), FoodItem.kDatabaseName);
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE regions('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'display_name TEXT UNIQUE NOT NULL,'
          'sanitized_name TEXT UNIQUE NOT NULL,'
          'created_at TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)',
        );
        await db.execute(
          'CREATE TABLE ${_foodTableName(FoodItem.kDefaultRegionSanitized)}('
          '${FoodItem.kColName} TEXT PRIMARY KEY,'
          '${FoodItem.kColPrice} DOUBLE,'
          '${FoodItem.kColProtein} INT,'
          '${FoodItem.kColKcal} INT,'
          '${FoodItem.kColGrams} INT)',
        );
        await db.execute(
          "INSERT INTO regions (display_name, sanitized_name, created_at) "
          "VALUES ('${FoodItem.kDefaultRegionDisplay}', '${FoodItem.kDefaultRegionSanitized}', "
          "datetime('now'))",
        );
        await db.execute(
          "INSERT INTO settings (key, value) VALUES ('${FoodItem.kActiveRegionKey}', '${FoodItem.kDefaultRegionSanitized}')",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateV1toV2(db);
        }
      },
    );
  }

  Future<void> _migrateV1toV2(Database db) async {
    await db.execute(
      'CREATE TABLE regions('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'display_name TEXT UNIQUE NOT NULL,'
      'sanitized_name TEXT UNIQUE NOT NULL,'
      'created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)',
    );
    final List<Map<String, dynamic>> oldItems =
        await db.query(FoodItem.kTableName);
    final tableName = _foodTableName(FoodItem.kDefaultRegionSanitized);
    await db.execute(
      'CREATE TABLE $tableName('
      '${FoodItem.kColName} TEXT PRIMARY KEY,'
      '${FoodItem.kColPrice} DOUBLE,'
      '${FoodItem.kColProtein} INT,'
      '${FoodItem.kColKcal} INT,'
      '${FoodItem.kColGrams} INT)',
    );
    for (final item in oldItems) {
      await db.insert(tableName, item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await db.execute(
      "INSERT INTO regions (display_name, sanitized_name, created_at) "
      "VALUES ('${FoodItem.kDefaultRegionDisplay}', '${FoodItem.kDefaultRegionSanitized}', "
      "datetime('now'))",
    );
    await db.execute(
      "INSERT INTO settings (key, value) VALUES ('${FoodItem.kActiveRegionKey}', '${FoodItem.kDefaultRegionSanitized}')",
    );
    await db.execute('DROP TABLE ${FoodItem.kTableName}');
    await db.execute('PRAGMA user_version = 2');
  }

  String _foodTableName(String sanitizedName) => 'foodItems_$sanitizedName';

  Future<void> migrateIfNeeded() async {
    final db = await database;
    final List<Map> result = await db.rawQuery('PRAGMA user_version');
    final int version = result.first['user_version'] as int;
    if (version < 2) {
      await _migrateV1toV2(db);
    }
  }

  Future<Region> getActiveRegion() async {
    final db = await database;
    final List<Map> result = await db.rawQuery(
      "SELECT display_name, sanitized_name FROM regions r "
      "JOIN settings s ON r.sanitized_name = s.value "
      "WHERE s.key = '${FoodItem.kActiveRegionKey}'",
    );
    if (result.isEmpty) {
      return Region(
          displayName: FoodItem.kDefaultRegionDisplay,
          sanitizedName: FoodItem.kDefaultRegionSanitized);
    }
    return Region(
      displayName: result.first['display_name'] as String,
      sanitizedName: result.first['sanitized_name'] as String,
    );
  }

  Future<void> setActiveRegion(String sanitizedName) async {
    final db = await database;
    await db.update(
      'settings',
      {'value': sanitizedName},
      where: 'key = ?',
      whereArgs: [FoodItem.kActiveRegionKey],
    );
  }

  Future<List<Region>> getAllRegions() async {
    final db = await database;
    final List<Map> result =
        await db.query('regions', orderBy: 'created_at ASC');
    return result
        .map((row) => Region(
              displayName: row['display_name'] as String,
              sanitizedName: row['sanitized_name'] as String,
            ))
        .toList();
  }

  String sanitizeRegionName(String displayName) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) throw ArgumentError('Region name cannot be empty');
    final sanitized = trimmed
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (sanitized.isEmpty) {
      throw ArgumentError('Region name must contain a letter');
    }
    if (sanitized.length > 50) {
      throw ArgumentError('Region name too long');
    }
    return sanitized;
  }

  Future<Region> createRegion(String displayName) async {
    final sanitized = sanitizeRegionName(displayName);
    final db = await database;
    await db.execute(
      'CREATE TABLE ${_foodTableName(sanitized)}('
      '${FoodItem.kColName} TEXT PRIMARY KEY,'
      '${FoodItem.kColPrice} DOUBLE,'
      '${FoodItem.kColProtein} INT,'
      '${FoodItem.kColKcal} INT,'
      '${FoodItem.kColGrams} INT)',
    );
    await db.insert('regions', {
      'display_name': displayName.trim(),
      'sanitized_name': sanitized,
      'created_at': DateTime.now().toIso8601String(),
    });
    return Region(displayName: displayName.trim(), sanitizedName: sanitized);
  }

  Future<void> renameRegion(
      String oldDisplayName, String newDisplayName) async {
    final db = await database;
    final List<Map> existing = await db.query(
      'regions',
      where: 'display_name = ?',
      whereArgs: [oldDisplayName],
    );
    if (existing.isEmpty) throw ArgumentError('Region not found');
    await db.update(
      'regions',
      {'display_name': newDisplayName.trim()},
      where: 'display_name = ?',
      whereArgs: [oldDisplayName],
    );
  }

  Future<int> getRegionFoodCount(String sanitizedName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${_foodTableName(sanitizedName)}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteRegion(String sanitizedName) async {
    final db = await database;
    final regions = await getAllRegions();
    if (regions.length <= 1) {
      throw ArgumentError('Cannot delete the last region');
    }
    if (sanitizedName == FoodItem.kDefaultRegionSanitized) {
      throw ArgumentError('Cannot delete the default region');
    }
    await db.execute('DROP TABLE ${_foodTableName(sanitizedName)}');
    await db.delete(
      'regions',
      where: 'sanitized_name = ?',
      whereArgs: [sanitizedName],
    );
    final active = await getActiveRegion();
    if (active.sanitizedName == sanitizedName) {
      final remaining = await getAllRegions();
      if (remaining.isNotEmpty) {
        await setActiveRegion(remaining.first.sanitizedName);
      }
    }
  }

  Future<List<FoodItem>> fetchFoodItems({String? regionSanitized}) async {
    final db = await database;
    String table;
    if (regionSanitized != null) {
      table = _foodTableName(regionSanitized);
    } else {
      final active = await getActiveRegion();
      table = _foodTableName(active.sanitizedName);
    }
    final List<Map<String, dynamic>> maps = await db.query(table);
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<void> addFoodItem(FoodItem foodItem, {String? regionSanitized}) async {
    final db = await database;
    String table;
    if (regionSanitized != null) {
      table = _foodTableName(regionSanitized);
    } else {
      final active = await getActiveRegion();
      table = _foodTableName(active.sanitizedName);
    }
    await db.insert(
      table,
      foodItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFoodItem(String name, {String? regionSanitized}) async {
    final db = await database;
    String table;
    if (regionSanitized != null) {
      table = _foodTableName(regionSanitized);
    } else {
      final active = await getActiveRegion();
      table = _foodTableName(active.sanitizedName);
    }
    await db.delete(
      table,
      where: '${FoodItem.kColName} = ?',
      whereArgs: [name],
    );
  }

  Future<void> modifyFoodItem(FoodItem foodItem,
      {String? regionSanitized}) async {
    final db = await database;
    String table;
    if (regionSanitized != null) {
      table = _foodTableName(regionSanitized);
    } else {
      final active = await getActiveRegion();
      table = _foodTableName(active.sanitizedName);
    }
    await db.update(
      table,
      foodItem.toMap(),
      where: '${FoodItem.kColName} = ?',
      whereArgs: [foodItem.name],
    );
  }

  Future<String> exportRegionSQL(String sanitizedName) async {
    final db = await database;
    final List<Map> regionRow = await db.query(
      'regions',
      where: 'sanitized_name = ?',
      whereArgs: [sanitizedName],
    );
    if (regionRow.isEmpty) throw ArgumentError('Region not found');
    final displayName = regionRow.first['display_name'] as String;
    final createdAt = regionRow.first['created_at'] as String;

    final buf = StringBuffer();
    buf.writeln('-- ProteinValue Region Export');
    buf.writeln('-- Region: $displayName');
    buf.writeln('-- Sanitized: $sanitizedName');
    buf.writeln('-- Exported: ${DateTime.now().toIso8601String()}');
    buf.writeln();
    buf.writeln(
        "INSERT OR IGNORE INTO regions (display_name, sanitized_name, created_at) "
        "VALUES ('${_escapeSql(displayName)}', '$sanitizedName', '$createdAt');");
    buf.writeln();
    buf.writeln('CREATE TABLE IF NOT EXISTS ${_foodTableName(sanitizedName)}('
        '${FoodItem.kColName} TEXT PRIMARY KEY,'
        '${FoodItem.kColPrice} DOUBLE,'
        '${FoodItem.kColProtein} INT,'
        '${FoodItem.kColKcal} INT,'
        '${FoodItem.kColGrams} INT);');

    final List<Map<String, dynamic>> items =
        await db.query(_foodTableName(sanitizedName));
    for (final item in items) {
      final f = FoodItem.fromMap(item);
      buf.writeln(f.toInsertSQL(_foodTableName(sanitizedName)));
    }
    return buf.toString();
  }

  Future<void> exportAndShare(String sql, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, fileName));
    await file.writeAsString(sql);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'ProteinValue Export',
    );
  }

  Future<String> importRegionSQL(String sqlContent) async {
    final db = await database;
    sqlContent = sqlContent.replaceAll('\r', '');

    final regionLine = sqlContent.split('\n').firstWhere(
          (l) => l.startsWith('-- Region:'),
          orElse: () => '',
        );
    final sanitizedLine = sqlContent.split('\n').firstWhere(
          (l) => l.startsWith('-- Sanitized:'),
          orElse: () => '',
        );
    final exportedLine = sqlContent.split('\n').firstWhere(
          (l) => l.startsWith('-- Exported:'),
          orElse: () => '',
        );

    if (regionLine.isEmpty) {
      throw ArgumentError('Invalid export file: missing Region header');
    }

    String displayName = regionLine.substring('-- Region:'.length).trim();
    final String originalSanitized = sanitizedLine.isNotEmpty
        ? sanitizedLine.substring('-- Sanitized:'.length).trim()
        : sanitizeRegionName(displayName);

    String exportTimestamp = '';
    if (exportedLine.isNotEmpty) {
      final rawTs = exportedLine.substring('-- Exported:'.length).trim();
      final isoTs = DateTime.tryParse(rawTs);
      if (isoTs != null) {
        exportTimestamp =
            '${isoTs.year}${_pad2(isoTs.month)}${_pad2(isoTs.day)}_'
            '${_pad2(isoTs.hour)}${_pad2(isoTs.minute)}${_pad2(isoTs.second)}';
      }
    }

    String sanitizedName = originalSanitized;
    String resolvedDisplayName = displayName;

    while (true) {
      final existing = await db.query(
        'regions',
        where: 'sanitized_name = ?',
        whereArgs: [sanitizedName],
      );
      if (existing.isEmpty) break;

      final suffix = exportTimestamp.isNotEmpty
          ? '_${exportTimestamp}_${DateTime.now().millisecondsSinceEpoch}'
          : '_${DateTime.now().millisecondsSinceEpoch}';
      resolvedDisplayName = '$resolvedDisplayName$suffix';
      sanitizedName = sanitizeRegionName(resolvedDisplayName);
      if (sanitizedName.length > 50) {
        sanitizedName = sanitizedName.substring(0, 50);
      }
    }

    if (sanitizedName.length > 50) {
      sanitizedName = sanitizedName.substring(0, 50);
    }
    displayName = resolvedDisplayName;

    final debugInfo = StringBuffer();
    debugInfo.writeln('displayName: "$displayName"');
    debugInfo.writeln('sanitizedName: "$sanitizedName"');

    final createdAt = _extractCreatedAtFromSql(sqlContent, originalSanitized);
    debugInfo.writeln('createdAt: "$createdAt"');

    final foodItems = _extractFoodItemsFromSql(sqlContent, originalSanitized);
    debugInfo.writeln('foodItems found: ${foodItems.length}');

    final errors = <String>[];
    int foodInserted = 0;

    try {
      await db.insert('regions', {
        'display_name': displayName,
        'sanitized_name': sanitizedName,
        'created_at': createdAt,
      });
    } catch (e) {
      errors.add('regions insert: $e');
    }

    try {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS ${_foodTableName(sanitizedName)}('
          '${FoodItem.kColName} TEXT PRIMARY KEY,'
          '${FoodItem.kColPrice} DOUBLE,'
          '${FoodItem.kColProtein} INT,'
          '${FoodItem.kColKcal} INT,'
          '${FoodItem.kColGrams} INT)');
    } catch (e) {
      errors.add('create table: $e');
    }

    for (final item in foodItems) {
      try {
        await db.insert(
          _foodTableName(sanitizedName),
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        foodInserted++;
      } catch (e) {
        errors.add('food insert (${item.name}): $e');
      }
    }

    debugInfo.writeln('errors: ${errors.length}');
    debugInfo.writeln('foodItems inserted: $foodInserted');
    if (errors.isNotEmpty) {
      debugInfo.writeln('Error details: ${errors.join('; ')}');
    }

    final check = await db.query(
      'regions',
      where: 'sanitized_name = ?',
      whereArgs: [sanitizedName],
    );
    debugInfo.writeln('post-verify rows: ${check.length}');
    if (check.isEmpty) {
      throw Exception('Verification failed\n\n${debugInfo.toString()}');
    }

    return displayName;
  }

  String _extractCreatedAtFromSql(String sql, String sanitized) {
    final insertPattern =
        "INSERT OR IGNORE INTO regions (display_name, sanitized_name, created_at) "
        "VALUES ('";
    final idx = sql.indexOf(insertPattern);
    if (idx < 0) return DateTime.now().toIso8601String();
    final valsStart = idx + insertPattern.length;

    int field = 0;
    int i = valsStart;
    while (i < sql.length) {
      if (sql[i] == "'") {
        int j = i + 1;
        final buf = StringBuffer();
        while (j < sql.length) {
          if (sql[j] == "'" && j + 1 < sql.length && sql[j + 1] == "'") {
            buf.write("'");
            j += 2;
          } else if (sql[j] == "'") {
            break;
          } else {
            buf.write(sql[j]);
            j++;
          }
        }
        field++;
        if (field == 3) {
          return buf.toString();
        }
        i = j + 1;
      } else {
        i++;
      }
    }
    return DateTime.now().toIso8601String();
  }

  List<FoodItem> _extractFoodItemsFromSql(String sql, String sanitized) {
    final tableName = _foodTableName(sanitized);
    final items = <FoodItem>[];
    int pos = 0;
    while (true) {
      final insertIdx = sql.indexOf("INSERT OR REPLACE INTO $tableName", pos);
      if (insertIdx < 0) break;
      final semiIdx = sql.indexOf(';', insertIdx);
      if (semiIdx < 0) break;
      final stmt = sql.substring(insertIdx, semiIdx);
      final valsIdx = stmt.indexOf('VALUES (');
      if (valsIdx < 0) break;
      final vals = stmt.substring(valsIdx + 'VALUES ('.length);
      final parts = _parseSqlValues(vals);
      if (parts.length >= 5) {
        try {
          items.add(FoodItem.create(
            name: parts[0],
            price: double.parse(parts[1]),
            protein100g: int.parse(parts[2]),
            kcal100g: int.parse(parts[3]),
            grams: int.parse(parts[4]),
          ));
        } catch (_) {}
      }
      pos = semiIdx + 1;
    }
    return items;
  }

  List<String> _parseSqlValues(String values) {
    final result = <String>[];
    int i = 0;
    while (i < values.length) {
      if (values[i] == ' ' || values[i] == '\n' || values[i] == '\t') {
        i++;
        continue;
      }
      if (values[i] == "'") {
        final buf = StringBuffer();
        int j = i + 1;
        while (j < values.length) {
          if (values[j] == "'" &&
              j + 1 < values.length &&
              values[j + 1] == "'") {
            buf.write("'");
            j += 2;
          } else if (values[j] == "'") {
            break;
          } else {
            buf.write(values[j]);
            j++;
          }
        }
        result.add(buf.toString());
        i = j + 1;
      } else if (values[i] == ',' || values[i] == ')') {
        i++;
      } else {
        final buf = StringBuffer();
        while (i < values.length &&
            values[i] != ',' &&
            values[i] != ')' &&
            values[i] != ' ' &&
            values[i] != '\n' &&
            values[i] != '\t') {
          buf.write(values[i]);
          i++;
        }
        result.add(buf.toString());
      }
    }
    return result;
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');

  Future<Region?> pickAndImportSQL() async {
    const typeGroup = XTypeGroup(
      label: 'SQL files',
      extensions: ['sql'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return null;

    final sqlContent = await file.readAsString();
    final displayName = await importRegionSQL(sqlContent);

    final sanitized = sanitizeRegionName(displayName);
    await setActiveRegion(sanitized);

    return Region(displayName: displayName, sanitizedName: sanitized);
  }

  String _escapeSql(String s) => s.replaceAll("'", "''");
}
