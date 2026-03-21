import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:proteinvalue/models/food_item.dart';
import 'package:proteinvalue/models/rankings.dart';
import 'package:proteinvalue/utils/ranking_calculator.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('FoodItem with RankingCalculator integration', () {
    test('calculates rankings for real food items', () {
      final chicken = FoodItem.create(
        name: 'Chicken Breast',
        price: 5.99,
        protein100g: 31,
        kcal100g: 165,
        grams: 150,
      );

      expect(
        RankingCalculator.calculate(chicken, Rankings.cheapProteinRich),
        closeTo(7.76, 0.01),
      );
      expect(
        RankingCalculator.calculate(chicken, Rankings.leanProteinRich),
        closeTo(0.188, 0.001),
      );
      expect(
        RankingCalculator.calculate(chicken, Rankings.cheapLeanProteinRich),
        closeTo(0.047, 0.001),
      );
      expect(
        RankingCalculator.calculate(chicken, Rankings.cheapHighCalorie),
        closeTo(41.32, 0.1),
      );
    });

    test('sorts foods by cheapProteinRich ranking', () {
      final foods = [
        FoodItem.create(
          name: 'Eggs',
          price: 2.00,
          protein100g: 13,
          kcal100g: 155,
          grams: 100,
        ),
        FoodItem.create(
          name: 'Chicken',
          price: 6.00,
          protein100g: 27,
          kcal100g: 240,
          grams: 100,
        ),
        FoodItem.create(
          name: 'Tuna',
          price: 3.00,
          protein100g: 29,
          kcal100g: 130,
          grams: 100,
        ),
      ];

      final sorted = List<FoodItem>.from(foods)
        ..sort((a, b) => RankingCalculator.cheapProteinRich(b)
            .compareTo(RankingCalculator.cheapProteinRich(a)));

      expect(sorted[0].name, equals('Tuna'));
      expect(sorted[1].name, equals('Eggs'));
      expect(sorted[2].name, equals('Chicken'));
    });

    test('sorts foods by leanProteinRich ranking', () {
      final foods = [
        FoodItem.create(
          name: 'Chicken',
          price: 5.00,
          protein100g: 31,
          kcal100g: 165,
          grams: 100,
        ),
        FoodItem.create(
          name: 'Tuna',
          price: 4.00,
          protein100g: 29,
          kcal100g: 130,
          grams: 100,
        ),
        FoodItem.create(
          name: 'Rice',
          price: 1.00,
          protein100g: 4,
          kcal100g: 130,
          grams: 100,
        ),
      ];

      final sorted = List<FoodItem>.from(foods)
        ..sort((a, b) => RankingCalculator.leanProteinRich(b)
            .compareTo(RankingCalculator.leanProteinRich(a)));

      expect(sorted[0].name, equals('Tuna'));
      expect(sorted[1].name, equals('Chicken'));
      expect(sorted[2].name, equals('Rice'));
    });
  });

  group('FoodItem serialization round-trip', () {
    test('survives map serialization with all fields', () {
      final original = FoodItem.create(
        name: '  Chicken Breast  ',
        price: 5.99,
        protein100g: 31,
        kcal100g: 165,
        grams: 150,
      );

      final map = original.toMap();
      final restored = FoodItem.fromMap(map);

      expect(restored.name, equals('Chicken Breast'));
      expect(restored.price, equals(5.99));
      expect(restored.protein100g, equals(31));
      expect(restored.kcal100g, equals(165));
      expect(restored.grams, equals(150));
      expect(restored, equals(original));
    });

    test('handles special characters in name', () {
      final original = FoodItem.create(
        name: "O'Brien's Best",
        price: 3.50,
        protein100g: 20,
        kcal100g: 100,
        grams: 100,
      );

      final map = original.toMap();
      final restored = FoodItem.fromMap(map);

      expect(restored.name, equals("O'Brien's Best"));
      expect(restored, equals(original));
    });
  });

  group('Rankings enum completeness', () {
    test('all ranking types have unique formulas', () {
      final formulas = Rankings.values.map((r) => r.formula).toSet();
      expect(formulas.length, equals(Rankings.values.length));
    });

    test('all ranking types have explanations', () {
      for (final ranking in Rankings.values) {
        expect(ranking.explanation.isNotEmpty, isTrue);
        expect(ranking.explanation, contains(ranking.formula));
      }
    });
  });
}
