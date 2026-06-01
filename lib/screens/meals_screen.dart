import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import '../models/enums.dart';
import '../providers/meal_provider.dart';
import '../services/meal_service.dart';
import '../services/shopping_service.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';

class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  late DateTime _weekStart;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  List<DateTime> get _weekDays => List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  String get _weekRangeLabel {
    final start = _weekDays.first;
    final end = _weekDays.last;
    final sm = _months[start.month - 1];
    final em = _months[end.month - 1];
    if (start.month == end.month) return '$sm ${start.day} – ${end.day}';
    return '$sm ${start.day} – $em ${end.day}';
  }

  void _prevWeek() {
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
    ref.read(selectedDateProvider.notifier).state = _weekStart;
  }

  void _nextWeek() {
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
    ref.read(selectedDateProvider.notifier).state = _weekStart;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final mealPlanAsync = ref.watch(mealPlanProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppHeader(
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: AppColors.forestGreen, size: 22),
            onPressed: () => context.push('/meal/new'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Meal Planner',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                const Text('Plan smart. Eat well. Feel your best.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                // Week navigator
                Row(
                  children: [
                    GestureDetector(
                      onTap: _prevWeek,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.chevron_left, size: 18, color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(_weekRangeLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _nextWeek,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.chevron_right, size: 18, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Day pills
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final day = _weekDays[i];
                      final isSelected = dateKey(day) == dateKey(selectedDate);
                      final isToday = dateKey(day) == dateKey(DateTime.now());
                      return GestureDetector(
                        onTap: () => ref.read(selectedDateProvider.notifier).state = day,
                        child: Container(
                          width: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.forestGreen : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.forestGreen : (isToday ? AppColors.orange : AppColors.border),
                              width: isToday && !isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _dayLabels[i],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.white : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.white : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: mealPlanAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (entries) {
                final totalKcal = entries.fold<int>(0, (sum, e) {
                  final cook = e.recipe?.recipe.cookTime ?? 0;
                  final prep = e.recipe?.recipe.prepTime ?? 0;
                  return sum + ((cook + prep) * 8);
                });
                final totalProtein = entries.length * 22;
                final totalCarbs = entries.length * 35;
                final totalFat = entries.length * 12;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    ...MealType.values.map((type) => _MealSection(
                      type: type,
                      entries: entriesForType(entries, type),
                      onRemove: (id) async {
                        await MealService.instance.removeMealPlanEntry(id);
                        ref.invalidate(mealPlanProvider);
                      },
                      onAdd: () => context.push('/meal/new'),
                      onTapRecipe: (id) => context.push('/meal/$id'),
                    )),

                    const SizedBox(height: 20),

                    // Macro summary card
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Macro Summary',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _MacroRow(label: 'Calories', value: '$totalKcal kcal', color: AppColors.orange),
                                    const SizedBox(height: 6),
                                    _MacroRow(label: 'Protein', value: '${totalProtein}g', color: AppColors.forestGreen),
                                    const SizedBox(height: 6),
                                    _MacroRow(label: 'Carbs', value: '${totalCarbs}g', color: Colors.blue),
                                    const SizedBox(height: 6),
                                    _MacroRow(label: 'Fat', value: '${totalFat}g', color: Colors.purple),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CustomPaint(
                                  painter: _DonutPainter(
                                    values: [totalKcal.toDouble(), totalProtein * 4, totalCarbs * 4, totalFat * 9],
                                    colors: [AppColors.orange, AppColors.forestGreen, Colors.blue, Colors.purple],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Generate grocery list banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ready to shop?',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                                SizedBox(height: 2),
                                Text('Generate your grocery list\nfrom this week\'s meal plan.',
                                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final start = dateKey(_weekStart);
                              final end = dateKey(_weekStart.add(const Duration(days: 6)));
                              await ShoppingService.instance.generateFromMealPlan(start, end);
                              ref.invalidate(shoppingItemsProvider);
                              if (context.mounted) context.go('/shopping');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(LucideIcons.shoppingCart, size: 14, color: AppColors.forestGreen),
                                  SizedBox(width: 6),
                                  Text('Generate List',
                                      style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.w700, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
    ],
  );
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  const _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -3.14159 / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 3.14159 * 2;
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.values != values;
}

class _MealSection extends StatelessWidget {
  final MealType type;
  final List<MealPlanRow> entries;
  final Future<void> Function(int) onRemove;
  final VoidCallback onAdd;
  final void Function(int) onTapRecipe;

  const _MealSection({
    required this.type,
    required this.entries,
    required this.onRemove,
    required this.onAdd,
    required this.onTapRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(type.label,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
              ],
            ),
            Row(
              children: [
                if (entries.isNotEmpty)
                  _PillBtn(label: 'Swap', icon: LucideIcons.refreshCw, onTap: onAdd),
                const SizedBox(width: 6),
                _PillBtn(label: 'Add', icon: LucideIcons.plus, onTap: onAdd, filled: true),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: const Text('No meals planned', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          )
        else
          ...entries.map((e) => _RecipeCard(
            entry: e,
            onRemove: onRemove,
            onTap: () => e.recipe != null ? onTapRecipe(e.recipe!.recipe.id) : null,
          )),
      ],
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _PillBtn({required this.label, required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? AppColors.forestGreen : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: filled ? AppColors.forestGreen : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: filled ? AppColors.white : AppColors.textDark),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: filled ? AppColors.white : AppColors.textDark,
              )),
        ],
      ),
    ),
  );
}

class _RecipeCard extends StatelessWidget {
  final MealPlanRow entry;
  final Future<void> Function(int) onRemove;
  final VoidCallback onTap;

  const _RecipeCard({required this.entry, required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = entry.recipe?.recipe.name ?? 'Unknown Recipe';
    final ingredients = entry.recipe?.ingredients ?? [];
    final ingredientPreview = ingredients.take(3).map((i) => i.name).join(', ');
    final prep = entry.recipe?.recipe.prepTime ?? 0;
    final cook = entry.recipe?.recipe.cookTime ?? 0;
    final totalTime = prep + cook;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food image placeholder
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.utensils, size: 28, color: AppColors.forestGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => onRemove(entry.entry.id),
                        child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (ingredientPreview.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(ingredientPreview,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatChip(icon: LucideIcons.flame, label: '~320 kcal', color: AppColors.orange),
                      const SizedBox(width: 6),
                      _StatChip(icon: LucideIcons.dumbbell, label: '22g protein', color: AppColors.forestGreen),
                      const SizedBox(width: 6),
                      if (totalTime > 0)
                        _StatChip(icon: LucideIcons.clock, label: '${totalTime}m', color: AppColors.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 2),
      Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    ],
  );
}
