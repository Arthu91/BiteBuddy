import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import '../models/enums.dart';
import '../providers/fasting_provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';
import '../widgets/progress_ring.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fasting = ref.watch(fastingProvider);
    final mealPlan = ref.watch(mealPlanProvider);
    final shopping = ref.watch(shoppingItemsProvider);

    final mealCount = mealPlan.valueOrNull?.length ?? 0;
    final shoppingCount = shopping.valueOrNull?.where((i) => !i.checked).length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppHeader(
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userCircle, color: AppColors.textMuted),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_greeting()}, Alex! 👋',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      const Text("You've got this! Small prep today,\nbig wins tomorrow.",
                          style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4)),
                    ],
                  ),
                ),
                Image.asset('assets/images/hype.png', height: 90),
              ],
            ),
            const SizedBox(height: 16),

            // Today at a glance
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today at a glance',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _GlanceItem(icon: '✅', value: '$mealCount/3', label: 'Meals prepped', color: AppColors.forestGreen),
                      _vDivider(),
                      _GlanceItem(icon: '🔥', value: '${fasting.session?.targetHours ?? 16}h', label: 'Fasting goal', color: AppColors.orange),
                      _vDivider(),
                      _GlanceItem(icon: '📋', value: '$shoppingCount', label: 'Items on list', color: AppColors.forestGreen),
                      _vDivider(),
                      const _GlanceItem(icon: '💧', value: '1.6L', label: 'Water goal', color: AppColors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Fasting card
            AppCard(
              onTap: () => context.go('/fasting'),
              child: Row(
                children: [
                  ProgressRing(
                    progress: fasting.progress,
                    size: 80,
                    strokeWidth: 8,
                    progressColor: fasting.isActive ? AppColors.forestGreen : AppColors.border,
                    child: Text(
                      fasting.isActive ? fasting.elapsedFormatted.substring(0, 4) : '--',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              fasting.isActive ? "You're fasting" : 'Start fasting',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
                              child: Text(fasting.protocol.label,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.forestGreen)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fasting.isActive ? "Great job! You're on track." : 'Tap to begin your fast',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fasting.progress,
                            minHeight: 6,
                            backgroundColor: AppColors.greenLight,
                            valueColor: const AlwaysStoppedAnimation(AppColors.forestGreen),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fasting.isActive
                                  ? 'Started ${_fmtTime(DateTime.fromMillisecondsSinceEpoch(fasting.session!.startTime))}'
                                  : '',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            Text(
                              fasting.isActive ? 'Goal ${_goalTime(fasting)}' : '',
                              style: const TextStyle(fontSize: 11, color: AppColors.forestGreen, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Today's meals + Shopping list
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Today's meals",
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                            GestureDetector(
                              onTap: () => context.go('/meals'),
                              child: const Text('View all',
                                  style: TextStyle(fontSize: 11, color: AppColors.forestGreen, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        mealPlan.when(
                          loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          error: (_, e) => const SizedBox(),
                          data: (entries) {
                            if (entries.isEmpty) {
                              return const Text('No meals today', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
                            }
                            return Column(
                              children: entries.take(3).map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(LucideIcons.utensils, size: 16, color: AppColors.forestGreen),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(e.recipe?.recipe.name ?? 'Meal',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              )).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Shopping list',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                            GestureDetector(
                              onTap: () => context.go('/shopping'),
                              child: const Text('View all',
                                  style: TextStyle(fontSize: 11, color: AppColors.forestGreen, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        shopping.when(
                          loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          error: (_, e) => const SizedBox(),
                          data: (items) {
                            if (items.isEmpty) {
                              return const Text('List is empty', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
                            }
                            return Column(
                              children: items.take(4).map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.checked ? Icons.check_circle : Icons.radio_button_unchecked,
                                      size: 16,
                                      color: item.checked ? AppColors.forestGreen : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(item.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: item.checked ? AppColors.textMuted : AppColors.textDark,
                                          decoration: item.checked ? TextDecoration.lineThrough : null,
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              )).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Macro trackers
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _TrackerItem(emoji: '💧', label: 'Water', value: '1.6', total: '2.0', unit: 'L', color: Colors.blue),
                  _vDivider(),
                  _TrackerItem(emoji: '💪', label: 'Protein', value: '72', total: '100', unit: 'g', color: AppColors.orange),
                  _vDivider(),
                  _TrackerItem(emoji: '🔥', label: 'Calories', value: '1,420', total: '1,800', unit: 'kcal', color: AppColors.forestGreen),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // AI Buddy suggestion
            AppCard(
              child: Row(
                children: [
                  Image.asset('assets/images/happy.png', height: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.sparkles, size: 14, color: AppColors.orange),
                            SizedBox(width: 4),
                            Text('AI Buddy suggestion',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try prepping a high-protein lunch tomorrow to help you stay full longer!',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => context.push('/ai'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text('Show me ideas',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';

  String _goalTime(FastingState s) {
    if (!s.isActive) return '';
    final goal = DateTime.fromMillisecondsSinceEpoch(s.session!.startTime)
        .add(Duration(hours: s.session!.targetHours));
    return _fmtTime(goal);
  }
}

Widget _vDivider() => Container(width: 1, height: 40, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 8));

class _GlanceItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  const _GlanceItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
      ],
    ),
  );
}

class _TrackerItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String total;
  final String unit;
  final Color color;
  const _TrackerItem({required this.emoji, required this.label, required this.value, required this.total, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 2),
        Text('$value / $total $unit', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: double.tryParse(value.replaceAll(',', ''))! / double.parse(total.replaceAll(',', '')),
            minHeight: 4,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    ),
  );
}
