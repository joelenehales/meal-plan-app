import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MealPlanner());
}

class MealPlanner extends StatelessWidget {
  const MealPlanner({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const RecipeListPage(title: 'Meal Planner'),
      title: 'Meal Planner',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 28, 108, 54)),
        useMaterial3: true,
      ),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key, required this.title});

  final String title;

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  int? selectedRecipe;
  final textController = TextEditingController();

  // Reload recipe list by refreshing the state
  // Used when returning home after adding a new recipe, so the new recipe shows up
  FutureOr refresh(dynamic value) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Meal Planner'),
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
                tooltip: 'New Recipe',
                child: const Icon(Icons.add_outlined),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewRecipePage()),
                  ).then(refresh);
                }),
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

//////////////////////////

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({super.key});

  @override
  State<NewRecipePage> createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  bool isChecked = false;
  List<int> selectedIngredientIds = [];
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add New Recipe'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Enter Recipe Name'),
            TextField(controller: textController),
            FutureBuilder<List<Ingredient>>(
                future: DatabaseHelper.instance.getIngredients(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Ingredient>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No Ingredients to Display'));
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.map((ingredient) {
                      // Display each ingredient with a checkbox
                      return CheckboxListTile(
                        title: Text(ingredient.name),
                        value: selectedIngredientIds.contains(ingredient.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              selectedIngredientIds.add(ingredient.id);
                            } else {
                              selectedIngredientIds.remove(ingredient.id);
                            }
                          });
                        },
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
                tooltip: 'Save',
                child: const Icon(Icons.add_outlined),
                onPressed: () async {
                  // Add recipe with the entered name and ingredients
                  int nextRecipeId =
                      await DatabaseHelper.instance.getNextAvailableRecipeId();
                  setState(() {
                    DatabaseHelper.instance.addRecipe(
                        Recipe(id: nextRecipeId, name: textController.text),
                        selectedIngredientIds);
                    // TODO: Give an error if no ingredients are selected
                  });
                  Navigator.pop(context); // Return to main menu
                }),
          ],
        ),
      ),
    );
  }
}

///////////////////////

// Represents a single recipe
class Recipe {
  final int id;
  final String name;
  // TODO: Add icon
  // TODO: Add type of cuisine

  Recipe({required this.id, required this.name});

  factory Recipe.fromMap(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Represents a single ingredient
class Ingredient {
  final int id;
  final String name;
  // TODO: Add type
  // TODO: Add icon

  Ingredient({required this.id, required this.name});

  factory Ingredient.fromMap(Map<String, dynamic> json) => Ingredient(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // If database does not exist, initialize database. Otherwise, use existing database.
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // Opens database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path,
        'appDatabase.db'); // FIXME: Make a better name for this
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Run when opening a database that does not yet exist. Creates all needed tables
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ingredients(
        id INTEGER PRIMARY KEY,
        name TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY,
        name TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE recipeIngredients(
        recipe_id INTEGER NOT NULL,
        ingredient_id INTEGER NOT NULL,
        FOREIGN KEY(recipe_id) REFERENCES recipes(id),
        FOREIGN KEY(ingredient_id) REFERENCES ingredients(id),
        PRIMARY KEY (recipe_id, ingredient_id)
      );
    ''');

    List<Ingredient> defaultIngredients = [
      Ingredient(id: 0, name: 'Tomato'),
      Ingredient(id: 1, name: 'Lettuce'),
      Ingredient(id: 2, name: 'Bread')
    ];

    for (var ingredient in defaultIngredients) {
      await db.insert('ingredients', ingredient.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Queries the database for all recipes and returns in a list
  Future<List<Recipe>> getRecipeList() async {
    Database db = await instance.database;
    var recipes = await db.query('recipes', orderBy: 'name');
    List<Recipe> recipeList = recipes.isNotEmpty
        ? recipes.map((c) => Recipe.fromMap(c)).toList()
        : [];
    return recipeList;
  }

  // Get next available recipe ID in the database
  Future<int> getNextAvailableRecipeId() async {
    Database db = await instance.database;
    var idQuery = await db.rawQuery('''SELECT MAX(id) FROM recipes;''');

    int id;
    if (idQuery.first['MAX(id)'] == null) {
      id = 0;
    } else {
      id = idQuery.first['MAX(id)'] as int;
      id += 1;
    }
    return id;
  }

  Future<List<Ingredient>> getIngredients() async {
    Database db = await instance.database;
    var ingredientsQuery = await db.query('ingredients', orderBy: 'name');
    List<Ingredient> ingredients = ingredientsQuery.isNotEmpty
        ? ingredientsQuery.map((c) => Ingredient.fromMap(c)).toList()
        : [];
    return ingredients;
  }

  // Queries the database for the ingredients in a recipe
  Future<List<Ingredient>> getRecipeIngredients(int recipeId) async {
    Database db = await instance.database;
    var ingredientQuery = await db.rawQuery('''
      SELECT * FROM ingredients WHERE id IN (
        SELECT ingredient_id FROM recipeIngredients 
        WHERE recipe_id = ?
      );
      ''', [recipeId]);
    List<Ingredient> ingredientList = ingredientQuery.isNotEmpty
        ? ingredientQuery.map((c) => Ingredient.fromMap(c)).toList()
        : [];
    return ingredientList;
  }

  // Queries the database for all ingredients and returns in a list
  Future<List<Ingredient>> allIngredients() async {
    Database db = await instance.database;
    var ingredients = await db.query('ingredients', orderBy: 'name');
    List<Ingredient> allIngredients = ingredients.isNotEmpty
        ? ingredients.map((c) => Ingredient.fromMap(c)).toList()
        : [];
    return allIngredients;
  }

  // Adds ingredient to the database
  Future<void> addIngredient(Ingredient ingredient) async {
    Database db = await instance.database;
    await db.insert('ingredients', ingredient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Adds recipe and its ingredients to databae
  Future<void> addRecipe(Recipe recipe, List<int> ingredientIds) async {
    Database db = await instance.database;
    await db.insert('recipes', recipe.toMap());
    for (var ingredientId in ingredientIds) {
      await db.insert('recipeIngredients',
          {'recipe_id': recipe.id, 'ingredient_id': ingredientId});
    }
  }

  // Removes recipe from list
  Future<void> removeRecipe(int recipeId) async {
    Database db = await instance.database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [recipeId]);
    await db.delete('recipeIngredients',
        where: 'recipe_id = ?', whereArgs: [recipeId]);
  }

  // Update a recipe
  // TODO: Add a way to update recipe ingredients
  Future<int> renameRecipe(Recipe recipe) async {
    Database db = await instance.database;
    return await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }
}
