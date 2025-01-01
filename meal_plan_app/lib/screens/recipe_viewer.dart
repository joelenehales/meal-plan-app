import 'package:flutter/material.dart';
import 'dart:async';

import 'package:meal_plan_app/database_helper.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/objects/ingredient.dart';
import 'package:meal_plan_app/widgets/ingredient_checkbox_widget.dart';
import 'package:meal_plan_app/widgets/recipe_ingredients_widgets.dart';

// Displays a single recipe with its ingredients
class RecipeViewer extends StatefulWidget {
  const RecipeViewer({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeViewer> createState() => _RecipeViewerState();
}

class _RecipeViewerState extends State<RecipeViewer> {
  late TextEditingController textController;
  late bool editMode = false;
  late String currentRecipeName; // Needed to update UI after renaming recipe
  List<int> selectedIngredientIds = [];

  void loadRecipeIngredients() async {
    List<Ingredient> ingredients =
        await DatabaseHelper.instance.getRecipeIngredients(widget.recipe.id);
    setState(() {
      selectedIngredientIds =
          ingredients.map((ingredient) => ingredient.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    currentRecipeName = widget.recipe.name;
    textController = TextEditingController(text: currentRecipeName);
    loadRecipeIngredients();
  }

  @override
  void dispose() {
    textController.dispose(); // Clean up controller to prevent memory leaks
    super.dispose();
  }

  FutureOr refresh(dynamic value) {
    setState(() {});
  }

  // Return recipe name as text editor in edit mode, or regular text otherwise
  Widget recipeNameWidget() {
    Widget nameWidget = editMode
        ? TextField(
            controller: textController,
            decoration: InputDecoration(
                labelText: 'Recipe Name',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: currentRecipeName),
          )
        : Text(currentRecipeName);
    return nameWidget;
  }

  // Return button to open edit mode or save changes
  Widget getEditButtonWidget() {
    Widget buttonWidget = editMode
        ? FloatingActionButton(
            tooltip: 'Save',
            child: const Icon(Icons.save),
            onPressed: () async {
              DatabaseHelper.instance.editRecipeIngredients(
                  widget.recipe.id, selectedIngredientIds);
              DatabaseHelper.instance.renameRecipe(
                  Recipe(id: widget.recipe.id, name: textController.text));
              setState(() {
                currentRecipeName = textController.text;
                editMode = false;
              });
            })
        : FloatingActionButton(
            tooltip: 'Edit Recipe',
            child: const Icon(Icons.edit),
            onPressed: () async {
              setState(() {
                editMode = true; // Toggle edit mode
              });
            });
    return buttonWidget;
  }

  // Returns list of ingredients in the recipe, or form to edit ingredients
  Widget ingredientsWidget() {
    List<Widget> widgets = [];
    for (var ingredientType in IngredientType.values) {
      if (editMode) {
        widgets.add(ExpansionTile(
            leading: ingredientType.icon,
            title: Text(ingredientType.name),
            children: <Widget>[
              IngredientCheckboxWidget(
                  selectedIngredientIds: selectedIngredientIds,
                  ingredientType: ingredientType)
            ]));
      } else {
        widgets.add(ListTile(
          leading: ingredientType.icon,
          title: Text(ingredientType.name),
        ));
        widgets.add(RecipeIngredientsWidget(
            recipe: widget.recipe, ingredientType: ingredientType));
      }
    }

    return Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Recipes'),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0), child: recipeNameWidget()),
          Expanded(child: SingleChildScrollView(child: ingredientsWidget())),
          Padding(
            // Keep buttons fixed at bottom
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  tooltip: 'Back',
                  child: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    Navigator.pop(context); // Return to recipe list
                  },
                ),
                const SizedBox(width: 20), // Spacing
                getEditButtonWidget(),
                const SizedBox(width: 20), // Spacing
                FloatingActionButton(
                  tooltip: 'Delete Recipe',
                  child: const Icon(Icons.delete_outlined),
                  onPressed: () async {
                    // TODO: Add confirmation to delete
                    setState(() {
                      DatabaseHelper.instance.removeRecipe(widget.recipe.id);
                    });
                    Navigator.pop(context); // Return to recipe list
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
