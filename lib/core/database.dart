import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// ── Tables ───────────────────────────────────────────────────────────────────

class Recipes extends Table {
  IntColumn get id          => integer().autoIncrement()();
  TextColumn get name       => text()();
  TextColumn get description => text().nullable()();
  IntColumn  get servings   => integer().withDefault(const Constant(1))();
  IntColumn  get prepTime   => integer().withDefault(const Constant(0))();
  IntColumn  get cookTime   => integer().withDefault(const Constant(0))();
  TextColumn get tags       => text().withDefault(const Constant(''))();
  IntColumn  get createdAt  => integer()();
}

class RecipeIngredients extends Table {
  IntColumn get id       => integer().autoIncrement()();
  IntColumn get recipeId => integer().references(Recipes, #id)();
  TextColumn get name    => text()();
  TextColumn get amount  => text().withDefault(const Constant(''))();
  TextColumn get unit    => text().withDefault(const Constant(''))();
}

class MealPlan extends Table {
  IntColumn get id       => integer().autoIncrement()();
  TextColumn get date    => text()();
  IntColumn  get recipeId => integer().references(Recipes, #id)();
  TextColumn get mealType => text()();
  IntColumn  get servings => integer().withDefault(const Constant(1))();
}

class FastingSessions extends Table {
  IntColumn get id          => integer().autoIncrement()();
  IntColumn get startTime   => integer()();
  IntColumn get endTime     => integer().nullable()();
  IntColumn get targetHours => integer()();
  BoolColumn get completed  => boolean().withDefault(const Constant(false))();
}

class ShoppingItems extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  TextColumn get name      => text()();
  TextColumn get amount    => text().withDefault(const Constant(''))();
  TextColumn get unit      => text().withDefault(const Constant(''))();
  TextColumn get category  => text().withDefault(const Constant('Other'))();
  BoolColumn get checked   => boolean().withDefault(const Constant(false))();
  BoolColumn get fromPlan  => boolean().withDefault(const Constant(false))();
  IntColumn  get createdAt => integer()();
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Recipes,
  RecipeIngredients,
  MealPlan,
  FastingSessions,
  ShoppingItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'bitebuddy');
  }

  Future<void> clearAll() async {
    await delete(shoppingItems).go();
    await delete(mealPlan).go();
    await delete(fastingSessions).go();
    await delete(recipeIngredients).go();
    await delete(recipes).go();
  }
}

// Singleton accessor
AppDatabase? _dbInstance;
AppDatabase get db {
  _dbInstance ??= AppDatabase();
  return _dbInstance!;
}
