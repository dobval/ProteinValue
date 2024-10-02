class FoodItem {
  final String name;
  final double price;
  final int protein100g;
  final int kcal100g;
  final int grams;

  FoodItem({
    required this.name,
    required this.price,
    required this.protein100g,
    required this.kcal100g,
    required this.grams,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'protein100g': protein100g,
      'kcal100g': kcal100g,
      'grams': grams,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
        name: map['name'],
        price: map['price'],
        protein100g: map['protein100g'],
        kcal100g: map['kcal100g'],
        grams: map['grams'],
    );
  }
}