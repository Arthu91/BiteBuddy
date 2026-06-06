import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import '../models/enums.dart';
import '../providers/fasting_provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_gradient_body.dart';
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

  String _dateLabel() {
    final d = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
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
      body: AppGradientBody(child: SingleChildScrollView(
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
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_dateLabel(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forestGreen)),
                      ),
                      const SizedBox(height: 6),
                      const Text('Small prep today, big wins tomorrow.',
                          style: TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4)),
                    ],
                  ),
                ),
                Image.asset('assets/images/hype.png', height: 90),
              ],
            ),
            const SizedBox(height: 16),

            // Today at a glance — colorful chipstrip (no card border)
            Row(
              children: [
                _GlanceChip(
                  icon: LucideIcons.utensils,
                  value: '$mealCount/3',
                  label: 'Meals',
                  iconColor: AppColors.forestGreen,
                  bgColor: AppColors.greenLight,
                ),
                const SizedBox(width: 8),
                _GlanceChip(
                  icon: LucideIcons.flame,
                  value: '${fasting.session?.targetHours ?? 16}h',
                  label: 'Fast goal',
                  iconColor: AppColors.orange,
                  bgColor: const Color(0xFFFFF0E6),
                ),
                const SizedBox(width: 8),
                _GlanceChip(
                  icon: LucideIcons.shoppingCart,
                  value: '$shoppingCount',
                  label: 'Shopping',
                  iconColor: AppColors.forestGreen,
                  bgColor: AppColors.greenLight,
                ),
                const SizedBox(width: 8),
                const _GlanceChip(
                  icon: LucideIcons.droplets,
                  value: '0L',
                  label: 'Water',
                  iconColor: AppColors.waterBlue,
                  bgColor: Color(0xFFEFF6FF),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick actions strip
            Row(
              children: [
                _QuickAction(label: '+ Add Meal', onTap: () => context.go('/meals')),
                const SizedBox(width: 8),
                _QuickAction(label: 'Shopping', onTap: () => context.go('/shopping'), outlined: true),
                const SizedBox(width: 8),
                _QuickAction(label: 'Progress', onTap: () => context.push('/progress'), outlined: true),
              ],
            ),
            const SizedBox(height: 16),

            // Fasting — hero card with gradient
            GestureDetector(
              onTap: () => context.go('/fasting'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [AppColors.forestGreen, Color(0xFF3D7A22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ProgressRing(
                      progress: fasting.progress,
                      size: 100,
                      strokeWidth: 10,
                      trackColor: Colors.white24,
                      progressColor: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fasting.isActive
                                ? fasting.elapsedFormatted.substring(0, 5)
                                : '--:--',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          if (fasting.isActive)
                            const Text('elapsed', style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  fasting.isActive ? "You're fasting" : 'Ready to fast?',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(fasting.protocol.label,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            fasting.isActive ? 'Great job! Keep it up.' : 'Tap to begin your fast',
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                          ),
                          if (fasting.isActive) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: fasting.progress,
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Started ${_fmtTime(DateTime.fromMillisecondsSinceEpoch(fasting.session!.startTime))}',
                                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                                ),
                                Text(
                                  'Goal ${_goalTime(fasting)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Start Fast →',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.forestGreen)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Macro trackers — 3 individual colored mini-cards
            Row(
              children: [
                Expanded(child: _MacroCard(
                  emoji: '💧',
                  label: 'Water',
                  value: 0,
                  total: 2.0,
                  unit: 'L',
                  color: AppColors.waterBlue,
                  bgColor: const Color(0xFFEFF6FF),
                )),
                const SizedBox(width: 10),
                Expanded(child: _MacroCard(
                  emoji: '💪',
                  label: 'Protein',
                  value: 0,
                  total: 100,
                  unit: 'g',
                  color: AppColors.orange,
                  bgColor: const Color(0xFFFFF0E6),
                )),
                const SizedBox(width: 10),
                Expanded(child: _MacroCard(
                  emoji: '🔥',
                  label: 'Calories',
                  value: 0,
                  total: 1800,
                  unit: 'kcal',
                  color: AppColors.forestGreen,
                  bgColor: AppColors.greenLight,
                )),
              ],
            ),
            const SizedBox(height: 14),

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
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                            GestureDetector(
                              onTap: () => context.go('/meals'),
                              child: const Text('View all',
                                  style: TextStyle(fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        mealPlan.when(
                          loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          error: (_, _) => const SizedBox(),
                          data: (entries) {
                            if (entries.isEmpty) {
                              return const Text('No meals today', style: TextStyle(color: AppColors.textMuted, fontSize: 13));
                            }
                            return Column(
                              children: entries.take(3).map((e) {
                                final type = MealTypeExt.fromString(e.entry.mealType);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 7),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.greenLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(type.emoji, style: const TextStyle(fontSize: 11)),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          e.recipe?.recipe.name ?? 'Meal',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
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
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                            GestureDetector(
                              onTap: () => context.go('/shopping'),
                              child: const Text('View all',
                                  style: TextStyle(fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        shopping.when(
                          loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          error: (_, _) => const SizedBox(),
                          data: (items) {
                            if (items.isEmpty) {
                              return const Text('List is empty', style: TextStyle(color: AppColors.textMuted, fontSize: 13));
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
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: item.checked ? AppColors.textMuted : AppColors.textDark,
                                          decoration: item.checked ? TextDecoration.lineThrough : null,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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
          ],
        ),
      )),
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

class _GlanceChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color bgColor;
  const _GlanceChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: iconColor)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textDark), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  const _QuickAction({required this.label, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.forestGreen,
        borderRadius: BorderRadius.circular(20),
        border: outlined ? Border.all(color: AppColors.border) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: outlined ? AppColors.textDark : Colors.white,
        ),
      ),
    ),
  );
}

class _MacroCard extends StatelessWidget {
  final String emoji;
  final String label;
  final double value;
  final double total;
  final String unit;
  final Color color;
  final Color bgColor;
  const _MacroCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.total,
    required this.unit,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / total).clamp(0.0, 1.0);
    final displayValue = unit == 'kcal' ? value.toInt().toString() : value.toString();
    final displayTotal = unit == 'kcal' ? total.toInt().toString() : total.toString();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              ProgressRing(
                progress: progress,
                size: 36,
                strokeWidth: 4,
                trackColor: Colors.white,
                progressColor: color,
                child: Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            unit == 'kcal' ? '$displayValue/$displayTotal' : '$displayValue/$displayTotal $unit',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}
