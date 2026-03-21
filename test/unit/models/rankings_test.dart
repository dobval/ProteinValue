import 'package:flutter_test/flutter_test.dart';
import 'package:proteinvalue/models/rankings.dart';

void main() {
  group('Rankings enum values', () {
    test('cheapProteinRich has correct properties', () {
      expect(
          Rankings.cheapProteinRich.displayName, equals('Cheap Protein-Rich'));
      expect(Rankings.cheapProteinRich.formula, equals('Protein/Price'));
      expect(
        Rankings.cheapProteinRich.explanation,
        contains('Protein/Price'),
      );
    });

    test('leanProteinRich has correct properties', () {
      expect(Rankings.leanProteinRich.displayName, equals('Lean Protein-Rich'));
      expect(Rankings.leanProteinRich.formula, equals('Protein/Kcal'));
      expect(
        Rankings.leanProteinRich.explanation,
        contains('Protein/Kcal'),
      );
    });

    test('cheapLeanProteinRich has correct properties', () {
      expect(
        Rankings.cheapLeanProteinRich.displayName,
        equals('Cheap Lean Protein-Rich'),
      );
      expect(
        Rankings.cheapLeanProteinRich.formula,
        equals('(Protein/Price)/Kcal'),
      );
      expect(
        Rankings.cheapLeanProteinRich.explanation,
        contains('(Protein/Price)/Kcal'),
      );
    });

    test('cheapHighCalorie has correct properties', () {
      expect(
        Rankings.cheapHighCalorie.displayName,
        equals('Cheap High-Calorie'),
      );
      expect(Rankings.cheapHighCalorie.formula, equals('Kcal/Price'));
      expect(
        Rankings.cheapHighCalorie.explanation,
        contains('Kcal/Price'),
      );
    });
  });

  group('Rankings count', () {
    test('has exactly 4 ranking types', () {
      expect(Rankings.values.length, equals(4));
    });

    test('contains all expected ranking types', () {
      expect(
        Rankings.values,
        containsAll([
          Rankings.cheapProteinRich,
          Rankings.leanProteinRich,
          Rankings.cheapLeanProteinRich,
          Rankings.cheapHighCalorie,
        ]),
      );
    });
  });

  group('Rankings properties', () {
    test('all rankings have non-empty displayName', () {
      for (final ranking in Rankings.values) {
        expect(ranking.displayName.isNotEmpty, isTrue);
      }
    });

    test('all rankings have non-empty formula', () {
      for (final ranking in Rankings.values) {
        expect(ranking.formula.isNotEmpty, isTrue);
      }
    });

    test('all rankings have non-empty explanation', () {
      for (final ranking in Rankings.values) {
        expect(ranking.explanation.isNotEmpty, isTrue);
      }
    });
  });
}
