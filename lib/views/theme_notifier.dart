import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  int _colorIndex = 0;

  // List of all built-in Material colors
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
    Colors.lightGreen, //9
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  // Method to cycle through colors
  void _changeColorScheme() {
    _colorIndex = (_colorIndex + 1) % _colors.length;
    notifyListeners(); // Notify listeners of change
  }

  // Get the current color scheme
  ThemeData get currentTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _colors[_colorIndex],
      ),
    );
  }

  // Method to expose for changing color
  void changeColor() {
    _changeColorScheme();
  }
}