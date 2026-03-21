import 'package:flutter_test/flutter_test.dart';
import 'package:proteinvalue/models/food_item.dart';

void main() {
  group('FoodItem.create() validation', () {
    test('throws ArgumentError when name is empty', () {
      expect(
        () => FoodItem.create(
          name: '',
          price: 1.0,
          protein100g: 10,
          kcal100g: 100,
          grams: 100,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when name is only whitespace', () {
      expect(
        () => FoodItem.create(
          name: '   ',
          price: 1.0,
          protein100g: 10,
          kcal100g: 100,
          grams: 100,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when price is negative', () {
      expect(
        () => FoodItem.create(
          name: 'Test Food',
          price: -1.0,
          protein100g: 10,
          kcal100g: 100,
          grams: 100,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when protein100g is negative', () {
      expect(
        () => FoodItem.create(
          name: 'Test Food',
          price: 1.0,
          protein100g: -5,
          kcal100g: 100,
          grams: 100,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when kcal100g is negative', () {
      expect(
        () => FoodItem.create(
          name: 'Test Food',
          price: 1.0,
          protein100g: 10,
          kcal100g: -50,
          grams: 100,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when grams is zero', () {
      expect(
        () => FoodItem.create(
          name: 'Test Food',
          price: 1.0,
          protein100g: 10,
          kcal100g: 100,
          grams: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when grams is negative', () {
      expect(
        () => FoodItem.create(
          name: 'Test Food',
          price: 1.0,
          protein100g: 10,
          kcal100g: 100,
          grams: -100,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('creates FoodItem with trimmed name', () {
      final food = FoodItem.create(
        name: '  Chicken Breast  ',
        price: 5.99,
        protein100g: 31,
        kcal100g: 165,
        grams: 150,
      );
      expect(food.name, equals('Chicken Breast'));
    });

    test('creates valid FoodItem with all valid inputs', () {
      final food = FoodItem.create(
        name: 'Test Food',
        price: 2.50,
        protein100g: 20,
        kcal100g: 200,
        grams: 100,
      );
      expect(food.name, equals('Test Food'));
      expect(food.price, equals(2.50));
      expect(food.protein100g, equals(20));
      expect(food.kcal100g, equals(200));
      expect(food.grams, equals(100));
    });

    test('accepts zero price (free items)', () {
      final food = FoodItem.create(
        name: 'Free Sample',
        price: 0.0,
        protein100g: 10,
        kcal100g: 50,
        grams: 50,
      );
      expect(food.price, equals(0.0));
    });

    test('accepts zero protein (non-protein foods)', () {
      final food = FoodItem.create(
        name: 'Pure Fat',
        price: 1.0,
        protein100g: 0,
        kcal100g: 900,
        grams: 10,
      );
      expect(food.protein100g, equals(0));
    });
  });

  group('FoodItem.toMap()', () {
    test('produces correct map with all fields', () {
      final food = FoodItem.create(
        name: 'Test Food',
        price: 3.50,
        protein100g: 25,
        kcal100g: 200,
        grams: 150,
      );
      final map = food.toMap();
      expect(map[FoodItem.kColName], equals('Test Food'));
      expect(map[FoodItem.kColPrice], equals(3.50));
      expect(map[FoodItem.kColProtein], equals(25));
      expect(map[FoodItem.kColKcal], equals(200));
      expect(map[FoodItem.kColGrams], equals(150));
    });
  });

  group('FoodItem.fromMap()', () {
    test('reconstructs FoodItem from map', () {
      final map = {
        FoodItem.kColName: 'From Map Food',
        FoodItem.kColPrice: 4.99,
        FoodItem.kColProtein: 30,
        FoodItem.kColKcal: 250,
        FoodItem.kColGrams: 200,
      };
      final food = FoodItem.fromMap(map);
      expect(food.name, equals('From Map Food'));
      expect(food.price, equals(4.99));
      expect(food.protein100g, equals(30));
      expect(food.kcal100g, equals(250));
      expect(food.grams, equals(200));
    });

    test('handles integer price in map', () {
      final map = {
        FoodItem.kColName: 'Int Price Food',
        FoodItem.kColPrice: 5,
        FoodItem.kColProtein: 10,
        FoodItem.kColKcal: 100,
        FoodItem.kColGrams: 100,
      };
      final food = FoodItem.fromMap(map);
      expect(food.price, equals(5.0));
    });
  });

  group('FoodItem serialization round-trip', () {
    test('toMap followed by fromMap produces equivalent object', () {
      final original = FoodItem.create(
        name: 'Round Trip Food',
        price: 6.75,
        protein100g: 22,
        kcal100g: 180,
        grams: 250,
      );
      final map = original.toMap();
      final restored = FoodItem.fromMap(map);
      expect(restored, equals(original));
    });
  });

  group('FoodItem equality', () {
    test('FoodItems with same values are equal', () {
      final food1 = FoodItem.create(
        name: 'Same Food',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final food2 = FoodItem.create(
        name: 'Same Food',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      expect(food1, equals(food2));
    });

    test('FoodItems with different names are not equal', () {
      final food1 = FoodItem.create(
        name: 'Food A',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final food2 = FoodItem.create(
        name: 'Food B',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      expect(food1, isNot(equals(food2)));
    });

    test('FoodItems with different prices are not equal', () {
      final food1 = FoodItem.create(
        name: 'Same Name',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final food2 = FoodItem.create(
        name: 'Same Name',
        price: 2.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      expect(food1, isNot(equals(food2)));
    });

    test('FoodItems with different protein are not equal', () {
      final food1 = FoodItem.create(
        name: 'Same Name',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final food2 = FoodItem.create(
        name: 'Same Name',
        price: 1.0,
        protein100g: 20,
        kcal100g: 100,
        grams: 100,
      );
      expect(food1, isNot(equals(food2)));
    });

    test('FoodItems with different kcal are not equal', () {
      final food1 = FoodItem.create(
        name: 'Same Name',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final food2 = FoodItem.create(
        name: 'Same Name',
        price: 1.0,
        protein100g: 10,
        kcal100g: 200,
        grams: 100,
      );
      expect(food1, isNot(equals(food2)));
    });

    test('FoodItems with different grams are not equal', () {
      final food1 = FoodItem.create(
        name: 'Same Name',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final food2 = FoodItem.create(
        name: 'Same Name',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 200,
      );
      expect(food1, isNot(equals(food2)));
    });

    test('FoodItem is not equal to non-FoodItem object', () {
      final food = FoodItem.create(
        name: 'Test',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      expect(food, isNot(equals('not a food item')));
      expect(food, isNot(equals(42)));
      expect(food, isNot(equals(null)));
    });
  });

  group('FoodItem hashCode', () {
    test('equal FoodItems have equal hashCodes', () {
      final food1 = FoodItem.create(
        name: 'Same Food',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      final food2 = FoodItem.create(
        name: 'Same Food',
        price: 1.0,
        protein100g: 10,
        kcal100g: 100,
        grams: 100,
      );
      expect(food1.hashCode, equals(food2.hashCode));
    });
  });

  group('FoodItem.toString()', () {
    test('returns formatted string representation', () {
      final food = FoodItem.create(
        name: 'Test Food',
        price: 1.50,
        protein100g: 10,
        kcal100g: 100,
        grams: 200,
      );
      expect(
        food.toString(),
        equals('FoodItem(name: Test Food, price: 1.5, protein100g: 10, '
            'kcal100g: 100, grams: 200)'),
      );
    });
  });

  group('FoodItem constants', () {
    test('column name constants are defined', () {
      expect(FoodItem.kColName, equals('name'));
      expect(FoodItem.kColPrice, equals('price'));
      expect(FoodItem.kColProtein, equals('protein100g'));
      expect(FoodItem.kColKcal, equals('kcal100g'));
      expect(FoodItem.kColGrams, equals('grams'));
    });

    test('database name constant is defined', () {
      expect(FoodItem.kDatabaseName, equals('foodItems.db'));
    });

    test('default region constants are defined', () {
      expect(FoodItem.kDefaultRegionDisplay, equals('DefaultRegion'));
      expect(FoodItem.kDefaultRegionSanitized, equals('defaultregion'));
      expect(FoodItem.kActiveRegionKey, equals('active_region'));
    });
  });
}
