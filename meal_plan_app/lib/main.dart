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
                                    onTap: () {
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
                    DatabaseHelper.instance.rename(
                        Recipe(id: selectedRecipe, name: textController.text));
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
                    DatabaseHelper.instance.remove(selectedRecipe!);
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
  List<int> selectedIngredients = [];
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add New Recipe'),
      ),

      // TODO: Test things are working by displaying all recipes
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
                      return Card(
                        // Each ingredient
                        child: Text(ingredient.name),
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
                  setState(() {
                    DatabaseHelper.instance
                        .add(Recipe(name: textController.text));
                    // TODO: In recipeIngredients table, add all ingredients
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
  final int? id; // ? means can be null
  final String name;

  Recipe({this.id, required this.name});

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
  final int? id; // ? means can be null
  final String name;
  // TODO: Add type
  // TODO: Add icon

  Ingredient({this.id, required this.name});

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
    print(documentsDirectory);
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
        recipe_id INTEGER,
        ingredient_id INTEGER,
        FOREIGN KEY(recipe_id) REFERENCES recipes(id),
        FOREIGN KEY(ingredient_id) REFERENCES ingredients(id)
      );
    ''');

    List<Ingredient> defaultIngredients = [
      Ingredient(name: 'Tomato'),
      Ingredient(name: 'Lettuce'),
      Ingredient(name: 'Bread')
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

  Future<List<Ingredient>> getIngredients() async {
    Database db = await instance.database;
    var ingredientsQuery = await db.query('ingredients', orderBy: 'name');
    List<Ingredient> ingredients = ingredientsQuery.isNotEmpty
        ? ingredientsQuery.map((c) => Ingredient.fromMap(c)).toList()
        : [];
    return ingredients;
  }

  // Queries the database for the ingredients in a recipe
  Future<List<Ingredient>> getRecipeIngredients(int id) async {
    Database db = await instance.database;
    var ingredientQuery = await db.rawQuery('''
      SELECT * FROM ingredients 
      WHERE ingredients.id IN (
        SELECT ingredientId 
        FROM recipeIngredients 
        WHERE recipeId = ?
      )
      ''', [id]);
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

  // Adds ingredient
  Future<int> addIngredient(Ingredient ingredient) async {
    Database db = await instance.database;
    return await db.insert('ingredients', ingredient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Adds recipe to list
  // TODO: Just name for now. Also allow it to add ingredients
  Future<int> add(Recipe recipe) async {
    Database db = await instance.database;
    return await db.insert('recipes', recipe.toMap());
  }

  // Removes recipe from list
  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
    // TODO: Remove from recipeIngredients
  }

  // Update a recipe
  // TODO: Add a way to update recipe ingredients
  Future<int> rename(Recipe recipe) async {
    Database db = await instance.database;
    return await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }
}
