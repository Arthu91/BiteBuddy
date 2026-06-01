import 'package:drift/drift.dart';
import '../core/database.dart';
import '../models/enums.dart';
import '../models/recipe_with_ingredients.dart';

class MealService {
  MealService._();
  static final instance = MealService._();

  // ── Recipes ────────────────────────────────────────────────────────────────

  Future<List<RecipeWithIngredients>> getAllRecipes() async {
    final rows = await db.select(db.recipes).get();
    return Future.wait(rows.map(_withIngredients));
  }

  Future<RecipeWithIngredients?> getRecipeById(int id) async {
    final row = await (db.select(db.recipes)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _withIngredients(row);
  }

  Future<RecipeWithIngredients> createRecipe({
    required String name,
    String? description,
    int servings = 1,
    int prepTime = 0,
    int cookTime = 0,
    String tags = '',
    List<({String name, String amount, String unit})> ingredients = const [],
  }) async {
    final id = await db.into(db.recipes).insert(RecipesCompanion.insert(
      name: name,
      description: Value(description),
      servings: Value(servings),
      prepTime: Value(prepTime),
      cookTime: Value(cookTime),
      tags: Value(tags),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));

    for (final ing in ingredients) {
      await db.into(db.recipeIngredients).insert(
        RecipeIngredientsCompanion.insert(
          recipeId: id,
          name: ing.name,
          amount: Value(ing.amount),
          unit: Value(ing.unit),
        ),
      );
    }

    return (await getRecipeById(id))!;
  }

  Future<void> deleteRecipe(int id) async {
    await (db.delete(db.recipeIngredients)
          ..where((t) => t.recipeId.equals(id)))
        .go();
    await (db.delete(db.recipes)..where((t) => t.id.equals(id))).go();
  }

  Future<RecipeWithIngredients> _withIngredients(Recipe row) async {
    final ings = await (db.select(db.recipeIngredients)
          ..where((t) => t.recipeId.equals(row.id)))
        .get();
    return RecipeWithIngredients(recipe: row, ingredients: ings);
  }

  // ── Meal Plan ──────────────────────────────────────────────────────────────

  Future<List<({MealPlanData entry, RecipeWithIngredients? recipe})>>
      getMealPlanForDate(String date) async {
    final rows = await (db.select(db.mealPlan)
          ..where((t) => t.date.equals(date)))
        .get();
    return _enrichEntries(rows);
  }

  Future<List<({MealPlanData entry, RecipeWithIngredients? recipe})>>
      getMealPlanRange(String start, String end) async {
    final rows = await (db.select(db.mealPlan)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end)))
        .get();
    return _enrichEntries(rows);
  }

  Future<List<({MealPlanData entry, RecipeWithIngredients? recipe})>>
      _enrichEntries(List<MealPlanData> rows) {
    return Future.wait(rows.map((r) async {
      final recipe = await getRecipeById(r.recipeId);
      return (entry: r, recipe: recipe);
    }));
  }

  Future<void> addMealPlanEntry({
    required String date,
    required int recipeId,
    required MealType mealType,
    int servings = 1,
  }) async {
    await db.into(db.mealPlan).insert(MealPlanCompanion.insert(
      date: date,
      recipeId: recipeId,
      mealType: mealType.name,
      servings: Value(servings),
    ));
  }

  Future<void> removeMealPlanEntry(int id) async {
    await (db.delete(db.mealPlan)..where((t) => t.id.equals(id))).go();
  }
}
