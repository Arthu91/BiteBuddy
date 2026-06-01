import '../core/database.dart';

class RecipeWithIngredients {
  final Recipe recipe;
  final List<RecipeIngredient> ingredients;

  const RecipeWithIngredients({
    required this.recipe,
    required this.ingredients,
  });

  List<String> get tagList => recipe.tags.isEmpty
      ? []
      : recipe.tags.split(',').map((t) => t.trim()).toList();
}
