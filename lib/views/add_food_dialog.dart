import 'package:flutter/material.dart';
import 'package:proteinvalue_flutter/models/food_item.dart';
import '../controllers/db_controller.dart';

class AddFoodDialog extends StatelessWidget {
  final DBController controller;

  const AddFoodDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController protein100gController = TextEditingController();
    final TextEditingController kcal100gController = TextEditingController();
    final TextEditingController gramsController = TextEditingController();

    return AlertDialog(
      title: const Text('Add Food'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent overflowing
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: protein100gController,
              decoration: const InputDecoration(labelText: 'Protein/100g'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: kcal100gController,
              decoration: const InputDecoration(labelText: 'Kcal/100g'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: gramsController,
              decoration: const InputDecoration(labelText: 'Grams'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Get input values and handle parsing safely
            final String name = nameController.text.trim();
            final double price = double.tryParse(priceController.text) ?? 0;
            final int protein100g = int.tryParse(protein100gController.text) ?? 0;
            final int kcal100g = int.tryParse(kcal100gController.text) ?? 0;
            final int grams = int.tryParse(gramsController.text) ?? 0;

            // Ensure that name is not empty
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Name cannot be empty')),
              );
              return;
            }

            final foodItem = FoodItem(
              name: name,
              price: price,
              protein100g: protein100g,
              kcal100g: kcal100g,
              grams: grams,
            );

            // Show a loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(child: CircularProgressIndicator()),
            );

            try {
              // Add food item to the database
              await controller.addFoodItem(foodItem);
              await controller.fetchFoodItems();

              // Close the loading indicator and dialog, returning 'true' as the result
              Navigator.of(context).pop(); // Close the loading indicator
              Navigator.of(context).pop(true); // Close the AddFoodDialog with result 'true'

            } catch (e) {
              // Handle errors
              Navigator.of(context).pop(); // Close the loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding food item: $e')),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
