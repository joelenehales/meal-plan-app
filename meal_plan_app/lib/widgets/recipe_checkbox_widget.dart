import 'package:flutter/material.dart';

import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/recipe.dart';

// TODO: Need to add ingredients tracking

// Helper class creates a widget that displays a list of recipes with
// checkboxes. Selected recipes are stored in a list by their ID.
class RecipeCheckboxWidget extends StatefulWidget {
  const RecipeCheckboxWidget({super.key, required this.selectedRecipeIds});

  final List<int> selectedRecipeIds; // Reference to external list

  @override
  State<RecipeCheckboxWidget> createState() => _RecipeCheckboxWidgetState();
}

class _RecipeCheckboxWidgetState extends State<RecipeCheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: DatabaseHelper.instance.getRecipeList(),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No recipes to display. Try adding one!'));
          // TODO: Add button here to add a new recipe
        }
        return Column(
          children: snapshot.data!.map((recipe) {
            return CheckboxListTile(
              title: Text(recipe.name, style: const TextStyle(fontSize: 16.0)),
              value: widget.selectedRecipeIds.contains(recipe.id),
              onChanged: (bool? value) {
                setState(() {
                  if (value!) {
                    widget.selectedRecipeIds.add(recipe.id);
                  } else {
                    widget.selectedRecipeIds.remove(recipe.id);
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
