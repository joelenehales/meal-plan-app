import 'package:flutter/material.dart';

import 'package:meal_plan_app/database_helper.dart';
import 'package:meal_plan_app/objects/ingredient.dart';

// Helper class creates a widget that displays a list of ingredients with
// checkboxes. Selected ingredients are stored in a list by their ID.
class IngredientCheckboxWidget extends StatefulWidget {
  const IngredientCheckboxWidget(
      {super.key,
      required this.selectedIngredientIds,
      required this.ingredientType});

  final List<int> selectedIngredientIds; // Reference to external list
  final IngredientType ingredientType;

  @override
  State<IngredientCheckboxWidget> createState() =>
      _IngredientCheckboxWidgetState();
}

class _IngredientCheckboxWidgetState extends State<IngredientCheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ingredient>>(
      future:
          DatabaseHelper.instance.getIngredientByType(widget.ingredientType),
      builder:
          (BuildContext context, AsyncSnapshot<List<Ingredient>> snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No ingredients to display'));
        }
        return ListView(
          shrinkWrap: true,
          children: snapshot.data!.map((ingredient) {
            return CheckboxListTile(
              title: Text(ingredient.name),
              value: widget.selectedIngredientIds.contains(ingredient.id),
              onChanged: (bool? value) {
                setState(() {
                  if (value!) {
                    widget.selectedIngredientIds.add(ingredient.id);
                  } else {
                    widget.selectedIngredientIds.remove(ingredient.id);
                  }
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}
