import 'package:flutter/material.dart';

import 'package:meal_plan_app/objects/ingredient.dart';
import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/database_helper.dart';

// Displays all recipes
class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  int? selectedRecipe;
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('All Recipes'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
                'Enter Recipe Name'), // TODO: Make this into a search bar
            TextField(controller: textController),
            // Displays all recipes
            FutureBuilder<List<Recipe>>(
                future: DatabaseHelper.instance.getRecipeList(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Recipe>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text('Loading...'));
                  }
                  return snapshot.data!
                          .isEmpty // Check if there are recipes to display
                      ? Center(child: Text('No Recipes to Display'))
                      : ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.map((recipe) {
                            return Center(
                              child: Card(
                                // Add gray colour to selected recipe
                                color: selectedRecipe == recipe.id
                                    ? Colors.white70
                                    : Colors.white,
                                // Each recipe
                                child: ListTile(
                                    title: Text(recipe.name),
                                    // List the recipe's ingredients
                                    subtitle: Column(
                                      children: <Widget>[
                                        FutureBuilder<List<Ingredient>>(
                                            future: DatabaseHelper.instance
                                                .getRecipeIngredients(
                                                    recipe.id),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<List<Ingredient>>
                                                    snapshot) {
                                              if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Center(
                                                    child:
                                                        Text('No Ingredients'));
                                              }
                                              return ListView(
                                                shrinkWrap: true,
                                                children: snapshot.data!
                                                    .map((ingredient) {
                                                  return Center(
                                                      child: ListTile(
                                                          title: Text(ingredient
                                                              .name)));
                                                }).toList(),
                                              );
                                            }),
                                      ],
                                    ),
                                    onTap: () {
                                      // Tap to select recipe to edit or remove
                                      setState(() {
                                        textController.text = recipe.name;
                                        selectedRecipe = recipe.id;
                                      });
                                    },
                                    onLongPress: () {
                                      // Press and hold to clear selected recipe
                                      setState(() {
                                        selectedRecipe = null;
                                      });
                                    }),
                              ),
                            );
                          }).toList(),
                        );
                }),
          ],
        ),
      ),

      floatingActionButton: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              tooltip: 'Rename Selected Recipe',
              child: const Icon(Icons.edit_outlined),
              onPressed: () async {
                // If recipe is selected, rename it to the entered text
                if (selectedRecipe != null) {
                  setState(() {
                    DatabaseHelper.instance.renameRecipe(
                        Recipe(id: selectedRecipe!, name: textController.text));
                  });
                }
              },
            ),
            FloatingActionButton(
              tooltip: 'Delete Selected Recipe',
              child: const Icon(Icons.delete_outlined),
              onPressed: () async {
                // If recipe is selected, remove it
                if (selectedRecipe != null) {
                  setState(() {
                    DatabaseHelper.instance.removeRecipe(selectedRecipe!);
                    textController.text = "";
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
