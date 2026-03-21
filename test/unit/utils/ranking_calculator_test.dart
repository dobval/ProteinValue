import 'package:flutter_test/flutter_test.dart';
import 'package:proteinvalue/models/food_item.dart';
import 'package:proteinvalue/models/rankings.dart';
import 'package:proteinvalue/utils/ranking_calculator.dart';

void main() {
  group('RankingCalculator.cheapProteinRich', () {
    test('calculates Protein/Price correctly', () {
      final food = FoodItem.create(
        name: 'Test Food',
        price: 2.00,
        protein100g: 20,
        kcal100g: 100,
        grams: 100,
      );
      expect(RankingCalculator.cheapProteinRich(food), equals(10.0));
    });

    test('returns 0 when price is zero', () {
      final food = FoodItem.create(
        name: 'Free Food',
        price: 0.0,
        protein100g: 20,
        kcal100g: 100,
        grams: 100,
      );
      expect(RankingCalculator.cheapProteinRich(food), equals(0.0));
    });

    test('handles different gram amounts', () {
      final food = FoodItem.create(
        name: 'Double Portion',
        price: 4.00,
        protein100g: 20,
        kcal100g: 100,
        grams: 200,
      );
      expect(RankingCalculator.cheapProteinRich(food), equals(10.0));
    });

    test('handles fractional price', () {
      final food = FoodItem.create(
        name: 'Cheap Food',
        price: 1.49,
        protein100g: 11,
        kcal100g: 100,
        grams: 500,
      );
      expect(RankingCalculator.cheapProteinRich(food), closeTo(36.91, 0.01));
    });
  });

  group('RankingCalculator.leanProteinRich', () {
    test('calculates Protein/Kcal correctly', () {
      final food = FoodItem.create(
        name: 'Test Food',
        price: 2.00,
        protein100g: 30,
        kcal100g: 150,
        grams: 100,
      );
      expect(RankingCalculator.leanProteinRich(food), equals(0.2));
    });

    test('returns 0 when kcal is zero', () {
      final food = FoodItem.create(
        name: 'Zero Cal Food',
        price: 2.00,
        protein100g: 30,
        kcal100g: 0,
        grams: 100,
      );
      expect(RankingCalculator.leanProteinRich(food), equals(0.0));
    });

    test('handles high protein, low calorie food', () {
      final food = FoodItem.create(
        name: 'Chicken Breast',
        price: 5.00,
        protein100g: 31,
        kcal100g: 165,
        grams: 150,
      );
      expect(RankingCalculator.leanProteinRich(food), closeTo(0.188, 0.001));
    });
  });

  group('RankingCalculator.cheapLeanProteinRich', () {
    test('calculates (Protein/Price)/Kcal correctly', () {
      final food = FoodItem.create(
        name: 'Test Food',
        price: 2.00,
        protein100g: 20,
        kcal100g: 100,
        grams: 100,
      );
      expect(RankingCalculator.cheapLeanProteinRich(food), equals(0.1));
    });

    test('returns 0 when price is zero', () {
      final food = FoodItem.create(
        name: 'Free Food',
        price: 0.0,
        protein100g: 20,
        kcal100g: 100,
        grams: 100,
      );
      expect(RankingCalculator.cheapLeanProteinRich(food), equals(0.0));
    });

    test('returns 0 when kcal is zero', () {
      final food = FoodItem.create(
        name: 'Zero Cal Food',
        price: 2.00,
        protein100g: 20,
        kcal100g: 0,
        grams: 100,
      );
      expect(RankingCalculator.cheapLeanProteinRich(food), equals(0.0));
    });

    test('favors cheap, high protein, low calorie foods', () {
      final food = FoodItem.create(
        name: 'Low Fat Cheese',
        price: 3.00,
        protein100g: 10,
        kcal100g: 50,
        grams: 100,
      );
      expect(
          RankingCalculator.cheapLeanProteinRich(food), closeTo(0.067, 0.001));
    });
  });

  group('RankingCalculator.cheapHighCalorie', () {
    test('calculates Kcal/Price correctly', () {
      final food = FoodItem.create(
        name: 'Test Food',
        price: 2.00,
        protein100g: 10,
        kcal100g: 200,
        grams: 100,
      );
      expect(RankingCalculator.cheapHighCalorie(food), equals(100.0));
    });

    test('returns 0 when price is zero', () {
      final food = FoodItem.create(
        name: 'Free Food',
        price: 0.0,
        protein100g: 10,
        kcal100g: 200,
        grams: 100,
      );
      expect(RankingCalculator.cheapHighCalorie(food), equals(0.0));
    });

    test('handles high calorie density foods', () {
      final food = FoodItem.create(
        name: 'Oil',
        price: 5.00,
        protein100g: 0,
        kcal100g: 900,
        grams: 100,
      );
      expect(RankingCalculator.cheapHighCalorie(food), equals(180.0));
    });
  });

  group('RankingCalculator.calculate', () {
    test('delegates to correct formula based on ranking type', () {
      final food = FoodItem.create(
        name: 'Test Food',
        price: 2.00,
        protein100g: 20,
        kcal100g: 100,
        grams: 100,
      );

      expect(
        RankingCalculator.calculate(food, Rankings.cheapProteinRich),
        equals(RankingCalculator.cheapProteinRich(food)),
      );
      expect(
        RankingCalculator.calculate(food, Rankings.leanProteinRich),
        equals(RankingCalculator.leanProteinRich(food)),
      );
      expect(
        RankingCalculator.calculate(food, Rankings.cheapLeanProteinRich),
        equals(RankingCalculator.cheapLeanProteinRich(food)),
      );
      expect(
        RankingCalculator.calculate(food, Rankings.cheapHighCalorie),
        equals(RankingCalculator.cheapHighCalorie(food)),
      );
    });
  });
}
