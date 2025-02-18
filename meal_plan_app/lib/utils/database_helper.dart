import 'dart:io';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:meal_plan_app/objects/recipe.dart';
import 'package:meal_plan_app/objects/ingredient.dart';
import 'package:meal_plan_app/objects/meal_plan.dart';

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
        name TEXT,
        type TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY,
        name TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE mealPlans(
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

    await db.execute('''
      CREATE TABLE mealPlanRecipes(
        meal_plan_id INTEGER NOT NULL,
        recipe_id INTEGER NOT NULL,
        FOREIGN KEY(meal_plan_id) REFERENCES mealPlans(id),
        FOREIGN KEY(recipe_id) REFERENCES recipes(id),
        PRIMARY KEY (meal_plan_id, recipe_id)
      );
    ''');

    _initializeIngredients(db);
  }

  // Initialize database with a lsit of ingredients
  void _initializeIngredients(Database db) async {
    int id = 0;
    List<Ingredient> defaultIngredients = [
      // Produce
      Ingredient(id: id++, name: 'Avocado', type: IngredientType.produce),
      Ingredient(id: id++, name: 'Kale', type: IngredientType.produce),
      Ingredient(id: id++, name: 'Lettuce', type: IngredientType.produce),
      Ingredient(id: id++, name: 'Onion', type: IngredientType.produce),
      Ingredient(id: id++, name: 'Bell Pepper', type: IngredientType.produce),
      Ingredient(id: id++, name: 'Spinach', type: IngredientType.produce),
      Ingredient(
          id: id++, name: 'Tomato (Hierloom)', type: IngredientType.produce),
      Ingredient(
          id: id++, name: 'Tomato (Cherry)', type: IngredientType.produce),
      // Dairy
      Ingredient(id: id++, name: 'Butter', type: IngredientType.dairy),
      Ingredient(id: id++, name: 'Eggs', type: IngredientType.dairy),
      Ingredient(id: id++, name: 'Milk', type: IngredientType.dairy),
      // Meat
      Ingredient(id: id++, name: 'Chicken (Thigh)', type: IngredientType.meat),
      Ingredient(id: id++, name: 'Chicken (Breast)', type: IngredientType.meat),
      Ingredient(id: id++, name: 'Chicken (Wing)', type: IngredientType.meat),
      Ingredient(id: id++, name: 'Bacon', type: IngredientType.meat),
      Ingredient(id: id++, name: 'Ground Beef', type: IngredientType.meat),
      // Seafood
      Ingredient(id: id++, name: 'Halibut', type: IngredientType.seafood),
      Ingredient(id: id++, name: 'Salmon', type: IngredientType.seafood),
      // Bakery
      Ingredient(id: id++, name: 'Bagel', type: IngredientType.bakery),
      Ingredient(id: id++, name: 'Bread', type: IngredientType.bakery),
      Ingredient(id: id++, name: 'Tortillas', type: IngredientType.bakery),
      // Pantry
      Ingredient(id: id++, name: 'Cashews', type: IngredientType.pantry),
      Ingredient(id: id++, name: 'Tomato Paste', type: IngredientType.pantry),
    ];

    for (var ingredient in defaultIngredients) {
      await db.insert('ingredients', ingredient.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Queries the database for all ingredients and returns in a list
  // TODO: This is currently not used
  Future<List<Ingredient>> getAllIngredients() async {
    Database db = await instance.database;
    var ingredients = await db.query('ingredients', orderBy: 'name');
    List<Ingredient> allIngredients = ingredients.isNotEmpty
        ? ingredients.map((c) => Ingredient.fromMap(c)).toList()
        : [];
    return allIngredients;
  }

  // Return all ingredients of a certain type
  Future<List<Ingredient>> getIngredientByType(IngredientType type) async {
    Database db = await instance.database;
    var ingredientsQuery = await db.query('ingredients',
        where: 'type = ?', whereArgs: [type.name], orderBy: 'name');
    List<Ingredient> ingredients = ingredientsQuery.isNotEmpty
        ? ingredientsQuery.map((c) => Ingredient.fromMap(c)).toList()
        : [];
    return ingredients;
  }

  // Adds ingredient to the database
  // TODO: This is currently unused
  Future<void> addIngredient(Ingredient ingredient) async {
    Database db = await instance.database;
    await db.insert('ingredients', ingredient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Queries the database for all recipes and returns in a list
  Future<List<Recipe>> getRecipeList() async {
    Database db = await instance.database;
    var recipesQuery = await db.query('recipes', orderBy: 'name');
    List<Recipe> recipeList = recipesQuery.isNotEmpty
        ? recipesQuery.map((c) => Recipe.fromMap(c)).toList()
        : [];
    return recipeList;
  }

  // Queries the database for all recipes and returns in a list
  Future<List<MealPlan>> getMealPlanList() async {
    Database db = await instance.database;
    var mealPlansQuery = await db.query('mealPlans', orderBy: 'name');
    List<MealPlan> mealPlanList = mealPlansQuery.isNotEmpty
        ? mealPlansQuery.map((c) => MealPlan.fromMap(c)).toList()
        : [];
    return mealPlanList;
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

  // Get next available meal plan ID in the database
  // TODO: Somehow reuse this code with the above, sub in different table name
  Future<int> getNextAvailableMealPlanId() async {
    Database db = await instance.database;
    var idQuery = await db.rawQuery('''SELECT MAX(id) FROM mealPlans;''');

    int id;
    if (idQuery.first['MAX(id)'] == null) {
      id = 0;
    } else {
      id = idQuery.first['MAX(id)'] as int;
      id += 1;
    }
    return id;
  }

  // Returns true if a recipe with the entered name already exists
  Future<bool> duplicateRecipeName(String name) async {
    Database db = await instance.database;
    var query = await db.query('recipes', where: 'name = ?', whereArgs: [name]);
    return query.isNotEmpty;
  }

  // Returns true if a meal plan with the entered name already exists
  // TODO: Can rename this and make a wrapper, reuse code from above
  Future<bool> duplicateMealPlanName(String name) async {
    Database db = await instance.database;
    var query =
        await db.query('mealPlans', where: 'name = ?', whereArgs: [name]);
    return query.isNotEmpty;
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

  // Queries the database for the ingredients in a recipe of a certain type
  Future<List<Ingredient>> getRecipeIngredientsByType(
      int recipeId, IngredientType type) async {
    Database db = await instance.database;
    var ingredientQuery = await db.rawQuery('''
      SELECT * FROM ingredients WHERE type = ? AND id IN (
        SELECT ingredient_id FROM recipeIngredients 
        WHERE recipe_id = ?
      );
      ''', [type.name, recipeId]);
    List<Ingredient> ingredientList = ingredientQuery.isNotEmpty
        ? ingredientQuery.map((c) => Ingredient.fromMap(c)).toList()
        : [];
    return ingredientList;
  }

  // Queries the database for the recipes in a meal plan
  Future<List<Recipe>> getMealPlanRecipes(int mealPlanId) async {
    Database db = await instance.database;
    var recipeQuery = await db.rawQuery('''
      SELECT * FROM recipes WHERE id IN (
        SELECT recipe_id FROM mealPlanRecipes 
        WHERE meal_plan_id = ?
      );
      ''', [mealPlanId]);
    List<Recipe> recipeList = recipeQuery.isNotEmpty
        ? recipeQuery.map((c) => Recipe.fromMap(c)).toList()
        : [];
    return recipeList;
  }

  // Queries the database for a list of all ingredients the meal plan
  // Returns the ingredient including its occurrences stored as a class variable
  Future<List<Ingredient>> getMealPlanIngredients(int mealPlanId) async {
    Database db = await instance.database;
    var ingredientsQuery = await db.rawQuery('''
      SELECT ingredients.id AS id, ingredients.name AS name, ingredients.type AS type, COUNT(recipeIngredients.recipe_id) AS occurrences FROM (
        (SELECT recipe_id FROM mealPlanRecipes WHERE meal_plan_id = ?) mealPlan
        INNER JOIN recipeIngredients ON mealPlan.recipe_id = recipeIngredients.recipe_id
        INNER JOIN ingredients ON  
        ingredients.id = recipeIngredients.ingredient_id
      ) GROUP BY ingredients.id;
      ''', [mealPlanId]);
    List<Ingredient> ingredientsList = ingredientsQuery.isNotEmpty
        ? ingredientsQuery.map((c) => Ingredient.fromMap(c)).toList()
        : [];
    return ingredientsList;
  }

  // Counts the number of ingredients the recipe shares with the list of recipes
  Future<int> getCommonIngredientCount(
      int recipeId, List<int> recipeIds) async {
    Database db = await instance.database;
    String placeholders = List.filled(recipeIds.length, '?').join(', ');

    String query = '''
      SELECT COUNT(DISTINCT recipe.ingredient_id) AS common_ingredient_count FROM
      (SELECT ingredient_id FROM recipeIngredients WHERE recipe_id = ?) recipe INNER JOIN
      (SELECT DISTINCT ingredient_id FROM recipeIngredients WHERE recipe_id IN ($placeholders)) recipeList
      ON recipe.ingredient_id = recipeList.ingredient_id;
    ''';

    List<Map<String, dynamic>> commonIngredientQuery =
        await db.rawQuery(query, [recipeId, ...recipeIds]);

    int commonIngredientCount =
        commonIngredientQuery.first['common_ingredient_count'] as int? ??
            0; // If null, set to 0
    return commonIngredientCount;
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

  // Adds a meal plan and its recipes to databae
  Future<void> addMealPlan(MealPlan mealPlan, List<int> recipeIds) async {
    Database db = await instance.database;
    await db.insert('mealPlans', mealPlan.toMap());
    for (var recipeId in recipeIds) {
      await db.insert('mealPlanRecipes',
          {'meal_plan_id': mealPlan.id, 'recipe_id': recipeId});
    }
  }

  // Removes recipe from database
  Future<void> removeRecipe(int recipeId) async {
    Database db = await instance.database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [recipeId]);
    await db.delete('recipeIngredients',
        where: 'recipe_id = ?', whereArgs: [recipeId]);
  }

  // Removes meal plan from database
  Future<void> removeMealPlan(int mealPlanId) async {
    Database db = await instance.database;
    await db.delete('mealPlans', where: 'id = ?', whereArgs: [mealPlanId]);
    await db.delete('mealPlanRecipes',
        where: 'meal_plan_id = ?', whereArgs: [mealPlanId]);
  }

  // Rename a recipe
  Future<int> renameRecipe(Recipe recipe) async {
    Database db = await instance.database;
    return await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }

  // Rename a meal plan
  Future<int> renameMealPlan(MealPlan mealPlan) async {
    Database db = await instance.database;
    return await db.update('mealPlans', mealPlan.toMap(),
        where: 'id = ?', whereArgs: [mealPlan.id]);
  }

  // Edit recipe ingredients
  Future<void> editRecipeIngredients(
      int recipeId, List<int> ingredientIds) async {
    Database db = await instance.database;

    await db.delete('recipeIngredients',
        where: 'recipe_id = ?', whereArgs: [recipeId]);

    for (var ingredientId in ingredientIds) {
      await db.insert('recipeIngredients',
          {'recipe_id': recipeId, 'ingredient_id': ingredientId});
    }
  }

  // Edit meal plan recipes
  Future<void> editMealPlanRecipes(int mealPlanId, List<int> recipeIds) async {
    Database db = await instance.database;

    await db.delete('mealPlanRecipes',
        where: 'meal_plan_id = ?', whereArgs: [mealPlanId]);

    for (var recipeId in recipeIds) {
      await db.insert('mealPlanRecipes',
          {'meal_plan_id': mealPlanId, 'recipe_id': recipeId});
    }
  }
}
