import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proteinvalue/views/theme_notifier.dart';

void main() {
  group('ThemeNotifier initialization', () {
    test('defaults to color index 0', () {
      final notifier = ThemeNotifier();
      expect(notifier.currentTheme.colorScheme.brightness,
          equals(Brightness.light));
    });

    test('uses provided initial color index', () {
      final notifier = ThemeNotifier(5);
      final theme = notifier.currentTheme;
      expect(theme.colorScheme.primary, isA<Color>());
      expect(theme.useMaterial3, isTrue);
    });

    test('accepts valid index at boundaries', () {
      final notifier0 = ThemeNotifier(0);
      final theme0 = notifier0.currentTheme;
      expect(theme0.colorScheme.primary, isA<Color>());

      final notifier17 = ThemeNotifier(17);
      final theme17 = notifier17.currentTheme;
      expect(theme17.colorScheme.primary, isA<Color>());
    });
  });

  group('ThemeNotifier.currentTheme', () {
    test('returns valid ThemeData with light brightness', () {
      final notifier = ThemeNotifier();
      final theme = notifier.currentTheme;

      expect(theme, isA<ThemeData>());
      expect(theme.colorScheme.brightness, equals(Brightness.light));
      expect(theme.scaffoldBackgroundColor, equals(Colors.white));
      expect(theme.canvasColor, equals(Colors.white));
      expect(theme.useMaterial3, isTrue);
    });

    test('uses Material 3 color scheme', () {
      final notifier = ThemeNotifier();
      final theme = notifier.currentTheme;

      expect(theme.colorScheme.primaryContainer, isNotNull);
      expect(theme.colorScheme.secondary, isNotNull);
      expect(theme.colorScheme.surface, isNotNull);
    });

    test('generates different themes for different color indices', () {
      final notifier0 = ThemeNotifier(0);
      final notifier1 = ThemeNotifier(1);
      final notifier17 = ThemeNotifier(17);

      final theme0 = notifier0.currentTheme;
      final theme1 = notifier1.currentTheme;
      final theme17 = notifier17.currentTheme;

      expect(theme0.colorScheme.primary,
          isNot(equals(theme1.colorScheme.primary)));
      expect(theme0.colorScheme.primary,
          isNot(equals(theme17.colorScheme.primary)));
      expect(theme1.colorScheme.primary,
          isNot(equals(theme17.colorScheme.primary)));
    });
  });

  group('ThemeNotifier constants', () {
    test('kColorCount is 18', () {
      expect(ThemeNotifier.kColorCount, equals(18));
    });

    test('kColorIndexKey is defined', () {
      expect(ThemeNotifier.kColorIndexKey, equals('color_index'));
    });
  });
}
