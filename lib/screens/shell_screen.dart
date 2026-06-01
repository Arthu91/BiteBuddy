import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';

const _tabRoutes = ['/home', '/meals', '/fasting', '/shopping'];

class ShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ShellScreen({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(icon: LucideIcons.home),
    _TabItem(icon: LucideIcons.calendarDays),
    _TabItem(icon: LucideIcons.timer),
    _TabItem(icon: LucideIcons.shoppingCart),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai'),
        backgroundColor: AppColors.forestGreen,
        elevation: 4,
        shape: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        height: 64,
        child: Row(
          children: [
            // Left: Home, Meals
            _NavItem(tab: _tabs[0], selected: idx == 0, onTap: () => context.go(_tabRoutes[0])),
            _NavItem(tab: _tabs[1], selected: idx == 1, onTap: () => context.go(_tabRoutes[1])),
            // Center gap for FAB
            const Expanded(child: SizedBox()),
            // Right: Fasting, Shopping
            _NavItem(tab: _tabs[2], selected: idx == 2, onTap: () => context.go(_tabRoutes[2])),
            _NavItem(tab: _tabs[3], selected: idx == 3, onTap: () => context.go(_tabRoutes[3])),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Icon(
        tab.icon,
        size: 24,
        color: selected ? AppColors.forestGreen : AppColors.textMuted,
      ),
    ),
  );
}

class _TabItem {
  final IconData icon;
  const _TabItem({required this.icon});
}
