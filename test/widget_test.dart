import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proteinvalue/models/food_item.dart';
import 'package:proteinvalue/views/add_food_dialog.dart';

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

  group('food item list interaction tests', () {
    testWidgets('tapping food item triggers onTap callback', (tester) async {
      bool tapped = false;
      final item = FoodItem.create(
        name: 'Chicken Breast',
        price: 5.99,
        protein100g: 31,
        kcal100g: 165,
        grams: 200,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            onTap: () => tapped = true,
            onLongPress: () {},
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(item.name, overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 1,
                      child: Text('${item.price}',
                          overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 1,
                      child: Text('${item.protein100g}',
                          overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 1,
                      child: Text('${item.kcal100g}',
                          overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 1,
                      child: Text('${item.grams}',
                          overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
        ),
      ));

      await tester.pump();
      await tester.tap(find.text('Chicken Breast'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('long-pressing food item triggers onLongPress callback',
        (tester) async {
      bool longPressed = false;
      final item = FoodItem.create(
        name: 'Eggs',
        price: 2.50,
        protein100g: 13,
        kcal100g: 155,
        grams: 100,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            onTap: () {},
            onLongPress: () => longPressed = true,
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(item.name, overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 1,
                      child: Text('${item.price}',
                          overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 1,
                      child: Text('${item.protein100g}',
                          overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 1,
                      child: Text('${item.kcal100g}',
                          overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 1,
                      child: Text('${item.grams}',
                          overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
        ),
      ));

      await tester.pump();
      await tester.longPress(find.text('Eggs'));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('food item list row displays all food item data correctly',
        (tester) async {
      final item = FoodItem.create(
        name: 'Greek Yogurt',
        price: 3.49,
        protein100g: 10,
        kcal100g: 59,
        grams: 150,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text(item.name, overflow: TextOverflow.ellipsis)),
                Expanded(
                    flex: 1,
                    child:
                        Text('${item.price}', overflow: TextOverflow.ellipsis)),
                Expanded(
                    flex: 1,
                    child: Text('${item.protein100g}',
                        overflow: TextOverflow.ellipsis)),
                Expanded(
                    flex: 1,
                    child: Text('${item.kcal100g}',
                        overflow: TextOverflow.ellipsis)),
                Expanded(
                    flex: 1,
                    child:
                        Text('${item.grams}', overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ));

      await tester.pump();

      expect(find.text('Greek Yogurt'), findsOneWidget);
      expect(find.text('3.49'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('59'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
    });
  });

  group('RED: food dialog edit mode tests', () {
    testWidgets('FoodDialog shows "Edit Food" title when editing',
        (tester) async {
      final item = FoodItem.create(
        name: 'Tuna',
        price: 4.00,
        protein100g: 25,
        kcal100g: 132,
        grams: 180,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => FoodDialog(
                    initialItem: item,
                    onSave: (_) async {},
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Food'), findsOneWidget);
    });

    testWidgets('FoodDialog shows "Update" button when editing',
        (tester) async {
      final item = FoodItem.create(
        name: 'Salmon',
        price: 8.00,
        protein100g: 20,
        kcal100g: 208,
        grams: 200,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => FoodDialog(
                    initialItem: item,
                    onSave: (_) async {},
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('FoodDialog pre-fills all fields from food item',
        (tester) async {
      final item = FoodItem.create(
        name: 'Beef Steak',
        price: 7.50,
        protein100g: 26,
        kcal100g: 271,
        grams: 250,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => FoodDialog(
                    initialItem: item,
                    onSave: (_) async {},
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Beef Steak'), findsOneWidget);
      expect(find.text('7.5'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
      expect(find.text('271'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
    });

    testWidgets('FoodDialog shows "Add Food" title in add mode',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => FoodDialog(
                    onSave: (_) async {},
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Add Food'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('FoodDialog calls onSave with updated item on submit',
        (tester) async {
      final item = FoodItem.create(
        name: 'Tofu',
        price: 3.00,
        protein100g: 8,
        kcal100g: 76,
        grams: 100,
      );
      FoodItem? savedItem;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (ctx) => FoodDialog(
                    initialItem: item,
                    onSave: (f) async => savedItem = f,
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Tofu Updated');

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(savedItem, isNotNull);
      expect(savedItem!.name, equals('Tofu Updated'));
    });
  });
}
