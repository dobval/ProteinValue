import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  static const String kColorIndexKey = 'color_index';
  static const int kColorCount = 18;

  int _colorIndex = 0;
  SharedPreferences? _prefs;

  final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  ThemeNotifier([int? initialColorIndex]) {
    if (initialColorIndex != null) {
      _colorIndex = initialColorIndex;
    }
  }

  Future<void> _saveColorIndex() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(kColorIndexKey, _colorIndex);
  }

  ThemeData get currentTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _colors[_colorIndex],
      ),
    );
  }

  void changeColor() {
    _colorIndex = (_colorIndex + 1) % kColorCount;
    notifyListeners();
    _saveColorIndex();
  }
}
