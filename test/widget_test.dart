import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SortBy {
  static const protein = _SortBy._('protein');

  final String _value;
  const _SortBy._(this._value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _SortBy && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}

Widget headerRow({required _SortBy currentSortBy, required bool isAscending}) {
  return Container(
    width: 300,
    height: 40,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child:
                  Text('Name', softWrap: true, overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 1,
              child: Text('Price',
                  softWrap: true, overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Protein/100g',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text('Kcal/100g',
                  softWrap: true, overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 1,
              child: Text('Grams',
                  softWrap: true, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget headerCellWithIcon({required bool isAscending}) {
  return Container(
    width: 150,
    height: 40,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Protein/100g',
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16.0),
      ],
    ),
  );
}

Widget dataRow() {
  return Container(
    width: 100,
    height: 40,
    color: Colors.white,
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Very Long Food Name That Could Wrap',
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Expanded(
          flex: 1,
          child:
              Text('999.99', softWrap: true, overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );
}

void main() {
  group('header and data row widget tests', () {
    testWidgets(
        'header row renders without overflow inside 40px height constraint',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: headerRow(
            currentSortBy: _SortBy.protein,
            isAscending: true,
          ),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Protein/100g'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Kcal/100g'), findsOneWidget);
      expect(find.text('Grams'), findsOneWidget);
    });

    testWidgets(
        'header cell with sort icon renders correctly in ascending order',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: headerCellWithIcon(isAscending: true),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.text('Protein/100g'), findsOneWidget);
    });

    testWidgets(
        'header cell with sort icon renders correctly in descending order',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: headerCellWithIcon(isAscending: false),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.text('Protein/100g'), findsOneWidget);
    });

    testWidgets(
        'header cell without sort icon (unsorted column) renders correctly',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Container(
            width: 150,
            height: 40,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Protein/100g',
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
      expect(find.text('Protein/100g'), findsOneWidget);
    });

    testWidgets('data row with long text renders without overflow',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: dataRow(),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Text), findsWidgets);
      expect(find.text('999.99'), findsOneWidget);
    });

    testWidgets('header row with narrow width renders without overflow',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 40,
            child: headerRow(
              currentSortBy: _SortBy.protein,
              isAscending: true,
            ),
          ),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Protein/100g'), findsOneWidget);
    });
  });
}
