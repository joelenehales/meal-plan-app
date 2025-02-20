import 'package:flutter/material.dart';
import 'dart:async';

import 'package:meal_plan_app/objects/meal_plan.dart';
import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/widgets/meal_plan_recipes_widget.dart';
import 'package:meal_plan_app/widgets/meal_plan_ingredients_widget.dart';
import 'package:meal_plan_app/widgets/recipe_select_widget.dart';

// Displays a single recipe with its ingredients
class MealPlanViewer extends StatefulWidget {
  const MealPlanViewer({super.key, required this.mealPlan});

  final MealPlan mealPlan;

  @override
  State<MealPlanViewer> createState() => _MealPlanViewerState();
}

class _MealPlanViewerState extends State<MealPlanViewer> {
  late TextEditingController textController;
  late bool editMode = false;
  late String
      currentMealPlanName; // Needed to update UI after renaming meal plan
  List<int> selectedRecipeIds = [];

  void loadMealPlanRecipes() async {
    List<Recipe> recipes =
        await DatabaseHelper.instance.getMealPlanRecipes(widget.mealPlan.id);
    setState(() {
      selectedRecipeIds = recipes.map((recipe) => recipe.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    currentMealPlanName = widget.mealPlan.name;
    textController = TextEditingController(text: currentMealPlanName);
    loadMealPlanRecipes();
  }

  @override
  void dispose() {
    textController.dispose(); // Clean up controller to prevent memory leaks
    super.dispose();
  }

  FutureOr refresh(dynamic value) {
    setState(() {});
  }

  // Return meal plan name as text editor in edit mode, or regular text otherwise
  Widget mealPlanNameWidget() {
    Widget nameWidget = editMode
        ? TextField(
            controller: textController,
            style: const TextStyle(fontSize: 24),
            decoration: InputDecoration(
                labelText: 'Meal Plan Name',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: currentMealPlanName),
          )
        : Text(currentMealPlanName, style: const TextStyle(fontSize: 24));
    return nameWidget;
  }

  // Return button to open edit mode or save changes
  Widget getEditButtonWidget() {
    Widget buttonWidget = editMode
        ? FloatingActionButton(
            tooltip: 'Save',
            heroTag: "save_meal_plan_edits",
            child: const Icon(Icons.save),
            onPressed: () async {
              DatabaseHelper.instance
                  .editMealPlanRecipes(widget.mealPlan.id, selectedRecipeIds);
              DatabaseHelper.instance.renameMealPlan(
                  MealPlan(id: widget.mealPlan.id, name: textController.text));
              setState(() {
                currentMealPlanName = textController.text;
                editMode = false;
              });
            })
        : FloatingActionButton(
            tooltip: 'Edit Meal Plan',
            heroTag: "edit_meal_plan",
            child: const Icon(Icons.edit),
            onPressed: () async {
              setState(() {
                editMode = true; // Toggle edit mode
              });
            });
    return buttonWidget;
  }

  // Returns list of recipes in the meal plan, or form to edit meal plans
  Widget recipesWidget() {
    Widget recipeWidget = editMode
        ? RecipeSelectWidget(selectedRecipeIds: selectedRecipeIds)
        : MealPlanRecipesWidget(mealPlan: widget.mealPlan);

    return recipeWidget;
  }

  // Returns a list of all ingredients in all recipes in the meal plan
  // TODO: Add ingredients occurrences
  Widget ingredientsWidget() {
    Widget ingredientWidget = editMode
        ? MealPlanIngredientsWidget(
            mealPlan: widget.mealPlan) // TODO: Handle edit mode differently
        : MealPlanIngredientsWidget(mealPlan: widget.mealPlan);
    return ingredientWidget;
  }
  // TODO: Separate by type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Meal Plans'),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0), child: mealPlanNameWidget()),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
            const Text('Recipes', style: TextStyle(fontSize: 20)),
            recipesWidget(),
            const Text('Ingredients', style: TextStyle(fontSize: 20)),
            ingredientsWidget()
          ]))),
          Padding(
            // Keep buttons fixed at bottom
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "back_meal_plan_viewer",
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
                  tooltip: 'Delete Meal Plan',
                  heroTag: "delete_meal_plan",
                  child: const Icon(Icons.delete_outlined),
                  onPressed: () async {
                    // TODO: Add confirmation to delete
                    setState(() {
                      DatabaseHelper.instance
                          .removeMealPlan(widget.mealPlan.id);
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
