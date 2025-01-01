import 'package:flutter/material.dart';
import 'dart:async';

import 'package:meal_plan_app/objects/meal_plan.dart';
import 'package:meal_plan_app/utils/database_helper.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/widgets/meal_plan_recipes_widget.dart';
import 'package:meal_plan_app/widgets/recipe_checkbox_widget.dart';

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
            decoration: InputDecoration(
                labelText: 'Meal Plan Name',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: currentMealPlanName),
          )
        : Text(currentMealPlanName);
    return nameWidget;
  }

  // Return button to open edit mode or save changes
  Widget getEditButtonWidget() {
    Widget buttonWidget = editMode
        ? FloatingActionButton(
            tooltip: 'Save',
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
        ? RecipeCheckboxWidget(selectedRecipeIds: selectedRecipeIds)
        : MealPlanRecipesWidget(mealPlan: widget.mealPlan);

    return recipeWidget;
  }

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
          Expanded(child: SingleChildScrollView(child: recipesWidget())),
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
                  tooltip: 'Delete Meal Plan',
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
