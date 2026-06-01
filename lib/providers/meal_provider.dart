import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database.dart';
import '../models/enums.dart';
import '../models/recipe_with_ingredients.dart';
import '../services/meal_service.dart';
import '../services/shopping_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

typedef MealPlanRow = ({MealPlanData entry, RecipeWithIngredients? recipe});

List<MealPlanRow> entriesForType(List<MealPlanRow> entries, MealType type) =>
    entries.where((e) => e.entry.mealType == type.name).toList();

// ── Providers ─────────────────────────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((_) => DateTime.now());

final recipesProvider = FutureProvider<List<RecipeWithIngredients>>(
    (_) => MealService.instance.getAllRecipes());

final mealPlanProvider = FutureProvider<List<MealPlanRow>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return MealService.instance.getMealPlanForDate(dateKey(date));
});

final shoppingItemsProvider = FutureProvider<List<ShoppingItem>>(
    (_) => ShoppingService.instance.getAll());
