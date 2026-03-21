class FoodItem {
  static const String kColName = 'name';
  static const String kColPrice = 'price';
  static const String kColProtein = 'protein100g';
  static const String kColKcal = 'kcal100g';
  static const String kColGrams = 'grams';
  static const String kDatabaseName = 'foodItems.db';

  static const String kDefaultRegionDisplay = 'DefaultRegion';
  static const String kDefaultRegionSanitized = 'defaultregion';
  static const String kActiveRegionKey = 'active_region';

  final String name;
  final double price;
  final int protein100g;
  final int kcal100g;
  final int grams;

  const FoodItem({
    required this.name,
    required this.price,
    required this.protein100g,
    required this.kcal100g,
    required this.grams,
  });

  factory FoodItem.create({
    required String name,
    required double price,
    required int protein100g,
    required int kcal100g,
    required int grams,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (price < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    if (protein100g < 0) {
      throw ArgumentError('Protein per 100g cannot be negative');
    }
    if (kcal100g < 0) {
      throw ArgumentError('Kcal per 100g cannot be negative');
    }
    if (grams <= 0) {
      throw ArgumentError('Grams must be greater than zero');
    }
    return FoodItem(
      name: name.trim(),
      price: price,
      protein100g: protein100g,
      kcal100g: kcal100g,
      grams: grams,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      kColName: name,
      kColPrice: price,
      kColProtein: protein100g,
      kColKcal: kcal100g,
      kColGrams: grams,
    };
  }

  String toInsertSQL(String tableName, String Function(String) escapeSql) {
    final escTable = escapeSql(tableName);
    final escName = escapeSql(name);
    return "INSERT OR REPLACE INTO $escTable ($kColName, $kColPrice, $kColProtein, $kColKcal, $kColGrams) "
        "VALUES ('$escName', $price, $protein100g, $kcal100g, $grams);";
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map[kColName] as String,
      price: (map[kColPrice] as num).toDouble(),
      protein100g: map[kColProtein] as int,
      kcal100g: map[kColKcal] as int,
      grams: map[kColGrams] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.name == name &&
        other.price == price &&
        other.protein100g == protein100g &&
        other.kcal100g == kcal100g &&
        other.grams == grams;
  }

  @override
  int get hashCode => Object.hash(name, price, protein100g, kcal100g, grams);

  @override
  String toString() {
    return 'FoodItem(name: $name, price: $price, protein100g: $protein100g, '
        'kcal100g: $kcal100g, grams: $grams)';
  }
}
