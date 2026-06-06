import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import '../core/database.dart';
import '../providers/fasting_provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_gradient_body.dart';
import '../widgets/app_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppHeader(
        showLogo: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: AppColors.textMuted),
            onPressed: () {},
          ),
        ],
      ),
      body: AppGradientBody(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Profile',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 2),
            const Text('Manage your health journey',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 20),

            // Profile card
            AppCard(
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle),
                        child: ClipOval(child: Image.asset('assets/images/happy.png', fit: BoxFit.cover)),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(color: AppColors.forestGreen, shape: BoxShape.circle),
                          child: const Icon(LucideIcons.pencil, size: 11, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex 👋',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark)),
                        SizedBox(height: 2),
                        Text('Ready to eat smarter today?',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text('Edit',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            AppCard(
              child: Row(
                children: [
                  _StatPill(label: 'Streak', value: '7 🔥', color: AppColors.orange),
                  _vDiv(),
                  _StatPill(label: 'Fasts Done', value: '24', color: AppColors.forestGreen),
                  _vDiv(),
                  _StatPill(label: 'Recipes', value: '12', color: Colors.blue),
                  _vDiv(),
                  _StatPill(label: 'Adherence', value: '86%', color: Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(label: 'Features'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuItem(
                    icon: LucideIcons.sparkles,
                    iconBg: AppColors.orange.withValues(alpha: 0.12),
                    iconColor: AppColors.orange,
                    label: 'AI Buddy',
                    trailing: _Badge('Gemini'),
                    onTap: () => context.push('/ai'),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  _MenuItem(
                    icon: LucideIcons.key,
                    iconBg: AppColors.greenLight,
                    iconColor: AppColors.forestGreen,
                    label: 'AI Settings',
                    onTap: () => context.push('/ai-settings'),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  _MenuItem(
                    icon: LucideIcons.barChart2,
                    iconBg: Colors.blue.withValues(alpha: 0.12),
                    iconColor: Colors.blue,
                    label: 'Progress & Insights',
                    onTap: () => context.push('/progress'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Health & Planning'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuItem(icon: LucideIcons.target, iconBg: AppColors.greenLight, iconColor: AppColors.forestGreen, label: 'Health Goals', onTap: null),
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  _MenuItem(icon: LucideIcons.leaf, iconBg: AppColors.greenLight, iconColor: AppColors.forestGreen, label: 'Dietary Preferences', onTap: null),
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  _MenuItem(icon: LucideIcons.timer, iconBg: AppColors.greenLight, iconColor: AppColors.forestGreen, label: 'Fasting Plan', onTap: null),
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  _MenuItem(icon: LucideIcons.bell, iconBg: AppColors.orange.withValues(alpha: 0.12), iconColor: AppColors.orange, label: 'Reminders', onTap: null),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Account'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuItem(icon: LucideIcons.database, iconBg: Colors.blue.withValues(alpha: 0.12), iconColor: Colors.blue, label: 'Storage & Data', onTap: null),
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  _MenuItem(icon: LucideIcons.shieldCheck, iconBg: AppColors.greenLight, iconColor: AppColors.forestGreen, label: 'Privacy', onTap: null),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mascot footer card
            AppCard(
              child: Row(
                children: [
                  Image.asset('assets/images/hype.png', height: 72),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("You're crushing it! 🥑",
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.forestGreen)),
                        SizedBox(height: 4),
                        Text('Every healthy choice you make is\na step toward a better you.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dev tools
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('onboarded');
                      if (context.mounted) context.go('/');
                    },
                    child: const Text('Reset onboarding', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Clear all data?'),
                          content: const Text('This will permanently delete all recipes, meals, fasting sessions, and shopping items.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Clear', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      await db.clearAll();
                      ref.invalidate(mealPlanProvider);
                      ref.invalidate(recipesProvider);
                      ref.invalidate(shoppingItemsProvider);
                      ref.invalidate(fastingProvider);
                      if (context.mounted) context.go('/home');
                    },
                    child: const Text('Clear all data', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

Widget _vDiv() => Container(width: 1, height: 36, color: AppColors.border);

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMuted)),
  );
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
      ],
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.iconBg, required this.iconColor, required this.label, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18) : null),
      onTap: onTap,
      dense: true,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: const TextStyle(color: AppColors.forestGreen, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
