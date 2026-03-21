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

  group('RankingCalculator.cheapProteinRich (protein/price)', () {
    test('rankings: best > good > ok (only protein varies)', () {
      final foods = [
        FoodItem.create(
            name: 'ok', price: 1.0, protein100g: 10, kcal100g: 100, grams: 100),
        FoodItem.create(
            name: 'good',
            price: 1.0,
            protein100g: 20,
            kcal100g: 100,
            grams: 100),
        FoodItem.create(
            name: 'best',
            price: 1.0,
            protein100g: 30,
            kcal100g: 100,
            grams: 100),
      ];

      final sorted = List<FoodItem>.from(foods)
        ..sort((a, b) => RankingCalculator.cheapProteinRich(b)
            .compareTo(RankingCalculator.cheapProteinRich(a)));

      expect(sorted[0].name, equals('best'));
      expect(sorted[1].name, equals('good'));
      expect(sorted[2].name, equals('ok'));
    });

    test('exact values: protein=20, price=1, grams=100 → 20.0', () {
      final food = FoodItem.create(
          name: 'Test', price: 1.0, protein100g: 20, kcal100g: 100, grams: 100);
      expect(RankingCalculator.cheapProteinRich(food), equals(20.0));
    });
  });

  group('RankingCalculator.leanProteinRich (protein/kcal)', () {
    test('rankings: best > good > ok (only protein varies)', () {
      final foods = [
        FoodItem.create(
            name: 'ok', price: 1.0, protein100g: 10, kcal100g: 100, grams: 100),
        FoodItem.create(
            name: 'good',
            price: 1.0,
            protein100g: 20,
            kcal100g: 100,
            grams: 100),
        FoodItem.create(
            name: 'best',
            price: 1.0,
            protein100g: 30,
            kcal100g: 100,
            grams: 100),
      ];

      final sorted = List<FoodItem>.from(foods)
        ..sort((a, b) => RankingCalculator.leanProteinRich(b)
            .compareTo(RankingCalculator.leanProteinRich(a)));

      expect(sorted[0].name, equals('best'));
      expect(sorted[1].name, equals('good'));
      expect(sorted[2].name, equals('ok'));
    });

    test('exact values: protein=25, kcal=100 → 0.25', () {
      final food = FoodItem.create(
          name: 'Test', price: 1.0, protein100g: 25, kcal100g: 100, grams: 100);
      expect(RankingCalculator.leanProteinRich(food), equals(0.25));
    });
  });

  group('RankingCalculator.cheapLeanProteinRich ((protein/price)/kcal)', () {
    test('rankings: best > good > ok (only protein varies)', () {
      final foods = [
        FoodItem.create(
            name: 'ok', price: 1.0, protein100g: 10, kcal100g: 100, grams: 100),
        FoodItem.create(
            name: 'good',
            price: 1.0,
            protein100g: 20,
            kcal100g: 100,
            grams: 100),
        FoodItem.create(
            name: 'best',
            price: 1.0,
            protein100g: 30,
            kcal100g: 100,
            grams: 100),
      ];

      final sorted = List<FoodItem>.from(foods)
        ..sort((a, b) => RankingCalculator.cheapLeanProteinRich(b)
            .compareTo(RankingCalculator.cheapLeanProteinRich(a)));

      expect(sorted[0].name, equals('best'));
      expect(sorted[1].name, equals('good'));
      expect(sorted[2].name, equals('ok'));
    });

    test('exact values: protein=50, kcal=100, price=1, grams=100 → 0.5', () {
      final food = FoodItem.create(
          name: 'Test', price: 1.0, protein100g: 50, kcal100g: 100, grams: 100);
      expect(RankingCalculator.cheapLeanProteinRich(food), equals(0.5));
    });
  });

  group('RankingCalculator.cheapHighCalorie (kcal/price)', () {
    test('rankings: best > good > ok (only kcal varies)', () {
      final foods = [
        FoodItem.create(
            name: 'ok', price: 1.0, protein100g: 10, kcal100g: 100, grams: 100),
        FoodItem.create(
            name: 'good',
            price: 1.0,
            protein100g: 10,
            kcal100g: 200,
            grams: 100),
        FoodItem.create(
            name: 'best',
            price: 1.0,
            protein100g: 10,
            kcal100g: 300,
            grams: 100),
      ];

      final sorted = List<FoodItem>.from(foods)
        ..sort((a, b) => RankingCalculator.cheapHighCalorie(b)
            .compareTo(RankingCalculator.cheapHighCalorie(a)));

      expect(sorted[0].name, equals('best'));
      expect(sorted[1].name, equals('good'));
      expect(sorted[2].name, equals('ok'));
    });

    test('exact values: kcal=250, price=1, grams=100 → 250.0', () {
      final food = FoodItem.create(
          name: 'Test', price: 1.0, protein100g: 10, kcal100g: 250, grams: 100);
      expect(RankingCalculator.cheapHighCalorie(food), equals(250.0));
    });
  });

  group('All rankings handle zero values', () {
    test('returns 0 when price is zero', () {
      final food = FoodItem.create(
          name: 'Test', price: 0.0, protein100g: 20, kcal100g: 100, grams: 100);

      expect(RankingCalculator.cheapProteinRich(food), equals(0.0));
      expect(RankingCalculator.cheapLeanProteinRich(food), equals(0.0));
      expect(RankingCalculator.cheapHighCalorie(food), equals(0.0));
    });

    test('returns 0 when kcal is zero', () {
      final food = FoodItem.create(
          name: 'Test', price: 1.0, protein100g: 20, kcal100g: 0, grams: 100);

      expect(RankingCalculator.leanProteinRich(food), equals(0.0));
      expect(RankingCalculator.cheapLeanProteinRich(food), equals(0.0));
    });
  });

  group('Rankings enum completeness', () {
    test('all 4 ranking types exist', () {
      expect(Rankings.values.length, equals(4));
    });

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

  group('FoodItem serialization round-trip', () {
    test('survives map serialization', () {
      final original = FoodItem.create(
        name: 'Chicken Breast',
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

    test('trims whitespace from name on create', () {
      final food = FoodItem.create(
        name: '  Chicken  ',
        price: 5.00,
        protein100g: 20,
        kcal100g: 100,
        grams: 100,
      );

      expect(food.name, equals('Chicken'));
    });
  });
}
