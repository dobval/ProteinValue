import 'package:proteinvalue/models/food_item.dart';
import 'package:proteinvalue/models/rankings.dart';

class RankingCalculator {
  static const double _kRatioScale = 100.0;

  static double cheapProteinRich(FoodItem item) {
    return item.price > 0
        ? (item.protein100g * item.grams) / (item.price * _kRatioScale)
        : 0.0;
  }

  static double leanProteinRich(FoodItem item) {
    return item.kcal100g > 0 ? item.protein100g / item.kcal100g : 0.0;
  }

  static double cheapLeanProteinRich(FoodItem item) {
    return (item.price > 0 && item.kcal100g > 0)
        ? (item.protein100g * item.grams) /
            (item.price * _kRatioScale * item.kcal100g)
        : 0.0;
  }

  static double cheapHighCalorie(FoodItem item) {
    return item.price > 0
        ? (item.kcal100g * item.grams) / (item.price * _kRatioScale)
        : 0.0;
  }

  static double calculate(FoodItem item, Rankings ranking) {
    switch (ranking) {
      case Rankings.cheapProteinRich:
        return cheapProteinRich(item);
      case Rankings.leanProteinRich:
        return leanProteinRich(item);
      case Rankings.cheapLeanProteinRich:
        return cheapLeanProteinRich(item);
      case Rankings.cheapHighCalorie:
        return cheapHighCalorie(item);
    }
  }
}
