import 'package:drift/drift.dart';
import '../core/database.dart';
import 'meal_service.dart';

class ShoppingService {
  ShoppingService._();
  static final instance = ShoppingService._();

  Future<List<ShoppingItem>> getAll() =>
      db.select(db.shoppingItems).get();

  Future<void> addItem({
    required String name,
    String amount = '',
    String unit = '',
    String category = 'Other',
    bool fromPlan = false,
  }) async {
    await db.into(db.shoppingItems).insert(ShoppingItemsCompanion.insert(
      name: name,
      amount: Value(amount),
      unit: Value(unit),
      category: Value(category),
      fromPlan: Value(fromPlan),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> toggle(int id, bool checked) async {
    await (db.update(db.shoppingItems)..where((t) => t.id.equals(id)))
        .write(ShoppingItemsCompanion(checked: Value(checked)));
  }

  Future<void> deleteItem(int id) async {
    await (db.delete(db.shoppingItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearChecked() async {
    await (db.delete(db.shoppingItems)
          ..where((t) => t.checked.equals(true)))
        .go();
  }

  Future<void> generateFromMealPlan(String startDate, String endDate) async {
    final entries = await MealService.instance.getMealPlanRange(startDate, endDate);
    for (final e in entries) {
      final rwi = e.recipe;
      if (rwi == null) continue;
      for (final ing in rwi.ingredients) {
        await addItem(
          name: ing.name,
          amount: ing.amount,
          unit: ing.unit,
          category: _guessCategory(ing.name),
          fromPlan: true,
        );
      }
    }
  }

  String _guessCategory(String name) {
    final n = name.toLowerCase();
    if (RegExp(r'chicken|beef|pork|fish|salmon|shrimp|turkey|egg').hasMatch(n)) {
      return 'Protein';
    }
    if (RegExp(r'milk|cheese|yogurt|butter|cream').hasMatch(n)) return 'Dairy';
    if (RegExp(r'apple|banana|tomato|lettuce|spinach|carrot|onion|garlic|pepper|broccoli|zucchini').hasMatch(n)) {
      return 'Produce';
    }
    if (RegExp(r'chip|cookie|nut|granola|bar').hasMatch(n)) return 'Snacks';
    if (RegExp(r'rice|pasta|flour|oil|vinegar|sauce|spice|salt|sugar|oat').hasMatch(n)) {
      return 'Pantry';
    }
    return 'Groceries';
  }
}
