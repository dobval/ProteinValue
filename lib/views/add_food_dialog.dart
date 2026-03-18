import 'package:flutter/material.dart';
import 'package:proteinvalue/models/food_item.dart';
import '../controllers/db_helper.dart';

class AddFoodDialog extends StatefulWidget {
  final DBController controller;

  const AddFoodDialog({
    super.key,
    required this.controller,
  });

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _protein100gController;
  late final TextEditingController _kcal100gController;
  late final TextEditingController _gramsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _protein100gController = TextEditingController();
    _kcal100gController = TextEditingController();
    _gramsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _protein100gController.dispose();
    _kcal100gController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Food'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _protein100gController,
              decoration: const InputDecoration(labelText: 'Protein/100g'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _kcal100gController,
              decoration: const InputDecoration(labelText: 'Kcal/100g'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _gramsController,
              decoration: const InputDecoration(labelText: 'Grams'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final String name = _nameController.text.trim();
    final double price = double.tryParse(_priceController.text) ?? 0;
    final int protein100g = int.tryParse(_protein100gController.text) ?? 0;
    final int kcal100g = int.tryParse(_kcal100gController.text) ?? 0;
    final int grams = int.tryParse(_gramsController.text) ?? 0;

    final FoodItem foodItem;
    try {
      foodItem = FoodItem.create(
        name: name,
        price: price,
        protein100g: protein100g,
        kcal100g: kcal100g,
        grams: grams,
      );
    } on ArgumentError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message.toString())),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await widget.controller.addFoodItem(foodItem);
      await widget.controller.fetchFoodItems();

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding food item: $e')),
      );
    }
  }
}
