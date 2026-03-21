import 'package:flutter_test/flutter_test.dart';
import 'package:proteinvalue/controllers/db_controller.dart';
import 'package:proteinvalue/models/food_item.dart';

void main() {
  late DBController controller;

  setUp(() {
    controller = DBController();
  });

  group('DBController.sanitizeRegionName', () {
    test('trims whitespace from input', () {
      expect(controller.sanitizeRegionName('  Berlin  '), equals('berlin'));
      expect(controller.sanitizeRegionName('\tParis\n'), equals('paris'));
      expect(controller.sanitizeRegionName('  City  with  spaces  '),
          equals('city__with__spaces'));
    });

    test('converts to lowercase', () {
      expect(controller.sanitizeRegionName('BERLIN'), equals('berlin'));
      expect(controller.sanitizeRegionName('NewYork'), equals('newyork'));
      expect(controller.sanitizeRegionName('HeLlO'), equals('hello'));
    });

    test('replaces spaces with underscores', () {
      expect(controller.sanitizeRegionName('New York'), equals('new_york'));
      expect(
          controller.sanitizeRegionName('Los Angeles'), equals('los_angeles'));
      expect(controller.sanitizeRegionName('a b c'), equals('a_b_c'));
    });

    test('replaces special characters with underscores', () {
      expect(controller.sanitizeRegionName('City@123'), equals('city_123'));
      expect(controller.sanitizeRegionName('Test-Case'), equals('test_case'));
      expect(controller.sanitizeRegionName('Name.Dot'), equals('name_dot'));
      expect(controller.sanitizeRegionName('Special#Chars!'),
          equals('special_chars_'));
      expect(
          controller.sanitizeRegionName('Umlaut: äöü'), equals('umlaut_____'));
    });

    test('keeps underscores and alphanumeric characters', () {
      expect(controller.sanitizeRegionName('region_1'), equals('region_1'));
      expect(controller.sanitizeRegionName('store_2_test'),
          equals('store_2_test'));
    });

    test('throws ArgumentError when input is empty', () {
      expect(() => controller.sanitizeRegionName(''),
          throwsA(isA<ArgumentError>()));
      expect(() => controller.sanitizeRegionName('   '),
          throwsA(isA<ArgumentError>()));
      expect(() => controller.sanitizeRegionName('\t\n'),
          throwsA(isA<ArgumentError>()));
    });

    test('converts non-alphanumeric to underscores', () {
      expect(controller.sanitizeRegionName('!!!'), equals('___'));
      expect(controller.sanitizeRegionName('   !!!   '), equals('___'));
    });

    test('accepts numeric-only names', () {
      expect(controller.sanitizeRegionName('12345'), equals('12345'));
      expect(controller.sanitizeRegionName('123'), equals('123'));
    });

    test('throws ArgumentError when name exceeds 50 characters', () {
      final longName = 'a' * 51;
      expect(() => controller.sanitizeRegionName(longName),
          throwsA(isA<ArgumentError>()));
    });

    test('accepts name with exactly 50 characters', () {
      final name50 = 'a' * 50;
      expect(controller.sanitizeRegionName(name50), equals(name50));
    });

    test('handles mixed case with spaces and special chars', () {
      expect(controller.sanitizeRegionName('Hello World!'),
          equals('hello_world_'));
      expect(
          controller.sanitizeRegionName('My City 123'), equals('my_city_123'));
    });

    test('multiple consecutive spaces become multiple underscores', () {
      expect(controller.sanitizeRegionName('a   b'), equals('a___b'));
    });
  });

  group('DBController._escapeSql (via FoodItem.toInsertSQL)', () {
    test('escapes single quotes in SQL output', () {
      final food = FoodItem.create(
        name: "Test's Food",
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final sql =
          food.toInsertSQL('test_table', (s) => s.replaceAll("'", "''"));
      expect(sql.contains("Test''s Food"), isTrue);
    });

    test('handles names without quotes', () {
      final food = FoodItem.create(
        name: 'SimpleName',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final sql =
          food.toInsertSQL('test_table', (s) => s.replaceAll("'", "''"));
      expect(sql.contains("SimpleName"), isTrue);
      expect(sql.contains("''"), isFalse);
    });

    test('escapes multiple quotes', () {
      final food = FoodItem.create(
        name: "John's 'Best' Food",
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final sql =
          food.toInsertSQL('test_table', (s) => s.replaceAll("'", "''"));
      expect(sql, contains("John''s ''Best'' Food"));
    });
  });
}
