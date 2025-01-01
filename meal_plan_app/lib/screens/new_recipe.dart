import 'package:flutter/material.dart';

import 'package:meal_plan_app/objects/ingredient.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/database_helper.dart';
import 'package:meal_plan_app/widgets/ingredient_checkbox_widget.dart';

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({super.key});

  @override
  State<NewRecipePage> createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  bool isChecked = false;
  List<int> selectedIngredientIds = [];
  final textController = TextEditingController();

  void showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // TODO: Redundant function in recipe_viewer.dart. Move elsewhere (ex. make a
  // "for all" version)
  Widget ingredientsCheckboxWidget() {
    List<Widget> widgets = [];
    for (var ingredientType in IngredientType.values) {
      widgets.add(ExpansionTile(
          leading: ingredientType.icon,
          title: Text(ingredientType.name),
          children: <Widget>[
            IngredientCheckboxWidget(
                selectedIngredientIds: selectedIngredientIds,
                ingredientType: ingredientType)
          ]));
    }
    return Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add New Recipe'),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                      labelText: 'Recipe Name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'New Recipe'))),
          Expanded(
              child: SingleChildScrollView(child: ingredientsCheckboxWidget())),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  tooltip: 'Save',
                  child: const Icon(Icons.save),
                  onPressed: () async {
                    String recipeName = textController.text;
                    // Show error if no ingredients have been selected
                    if (selectedIngredientIds.isEmpty) {
                      showErrorDialog('No ingredients selected.', context);
                    }
                    // Show error if no name is entered
                    else if (recipeName == "") {
                      showErrorDialog('No recipe name entered.', context);
                    }
                    // Duplicate recipe name
                    else if (await DatabaseHelper.instance
                        .duplicateRecipeName(recipeName)) {
                      showErrorDialog(
                          'Recipe with the entered name already exists.',
                          context);
                    }
                    // Valid input
                    else {
                      // Add recipe with the entered name and ingredients
                      int nextRecipeId = await DatabaseHelper.instance
                          .getNextAvailableRecipeId();
                      setState(() {
                        DatabaseHelper.instance.addRecipe(
                            Recipe(id: nextRecipeId, name: textController.text),
                            selectedIngredientIds);
                        // TODO: Give confirmation if entered successfully
                      });
                      Navigator.pop(context); // Return to recipe list
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
