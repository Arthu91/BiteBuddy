import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_colors.dart';
import '../../models/enums.dart';
import '../../models/recipe_with_ingredients.dart';
import '../../providers/meal_provider.dart';
import '../../services/meal_service.dart';
import '../../widgets/app_card.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late Future<RecipeWithIngredients?> _future;

  @override
  void initState() {
    super.initState();
    _future = MealService.instance.getRecipeById(widget.recipeId);
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('This will remove the recipe and all its meal plan entries.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await MealService.instance.deleteRecipe(widget.recipeId);
      ref.invalidate(recipesProvider);
      ref.invalidate(mealPlanProvider);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  void _showAddToPlanSheet(BuildContext context, RecipeWithIngredients rwi) {
    MealType selectedType = MealType.breakfast;
    DateTime selectedDate = DateTime.now();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add to Meal Plan',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark)),
              const SizedBox(height: 16),
              const Text('Meal type', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: MealType.values.map((t) {
                  final sel = t == selectedType;
                  return GestureDetector(
                    onTap: () => setModal(() => selectedType = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.forestGreen : AppColors.cream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? AppColors.forestGreen : AppColors.border),
                      ),
                      child: Text('${t.emoji} ${t.label}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: sel ? AppColors.white : AppColors.textDark)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    final dateStr = dateKey(selectedDate);
                    await MealService.instance.addMealPlanEntry(
                      date: dateStr,
                      recipeId: rwi.recipe.id,
                      mealType: selectedType,
                    );
                    ref.invalidate(mealPlanProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to ${selectedType.label}!'),
                          backgroundColor: AppColors.forestGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Add to Plan',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: FutureBuilder<RecipeWithIngredients?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final rwi = snap.data;
          if (rwi == null) {
            return const Center(child: Text('Recipe not found.'));
          }
          final r = rwi.recipe;
          final totalTime = r.prepTime + r.cookTime;

          return CustomScrollView(
            slivers: [
              // Large header image area
              SliverAppBar(
                expandedHeight: 220,
                backgroundColor: AppColors.greenLight,
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 20),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => _delete(context),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(LucideIcons.trash2, color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: AppColors.greenLight),
                      Center(child: Icon(LucideIcons.utensils, size: 80, color: AppColors.forestGreen.withValues(alpha: 0.3))),
                      if (rwi.tagList.isNotEmpty)
                        Positioned(
                          bottom: 12, left: 16,
                          child: Wrap(
                            spacing: 6,
                            children: rwi.tagList.take(3).map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.forestGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            )).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title + description
                    Text(r.name,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    if (r.description != null && r.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(r.description!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4)),
                    ],
                    const SizedBox(height: 16),

                    // Macro stats row
                    AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          _MacroStat(icon: LucideIcons.users, label: 'Servings', value: '${r.servings}', color: AppColors.forestGreen),
                          _vDivider(),
                          _MacroStat(icon: LucideIcons.clock, label: 'Prep', value: '${r.prepTime}m', color: Colors.blue),
                          _vDivider(),
                          _MacroStat(icon: LucideIcons.flame, label: 'Cook', value: '${r.cookTime}m', color: AppColors.orange),
                          _vDivider(),
                          _MacroStat(icon: LucideIcons.timer, label: 'Total', value: '${totalTime}m', color: Colors.purple),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ingredients + steps side layout
                    const Text('Ingredients',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    if (rwi.ingredients.isEmpty)
                      const Text('No ingredients listed.', style: TextStyle(color: AppColors.textMuted))
                    else
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: rwi.ingredients.map((ing) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(color: AppColors.forestGreen, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ing.name,
                                    style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  '${ing.amount} ${ing.unit}'.trim(),
                                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Add to meal plan button
                    GestureDetector(
                      onTap: () => _showAddToPlanSheet(context, rwi),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.calendarDays, color: AppColors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Add to Meal Plan',
                                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _vDivider() => Container(width: 1, height: 36, color: AppColors.border);

class _MacroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MacroStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    ),
  );
}
