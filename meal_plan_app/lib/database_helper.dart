import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'objects/recipe.dart';
import 'objects/ingredient.dart';

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
