import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_theme.dart';
import 'screens/ai_screen.dart';
import 'screens/ai_settings_screen.dart';
import 'screens/fasting_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/recipe/new_recipe_screen.dart';
import 'screens/recipe/recipe_detail_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/shopping_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    if (state.matchedLocation != '/') return null;
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarded') ?? false;
    return onboarded ? '/home' : null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, _) => const LandingScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, state, shell) => ShellScreen(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/home',     builder: (_, _) => const HomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/meals',    builder: (_, _) => const MealsScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/fasting',  builder: (_, _) => const FastingScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/shopping', builder: (_, _) => const ShoppingScreen())]),
      ],
    ),
    GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    GoRoute(path: '/meal/new',  builder: (_, _) => const NewRecipeScreen()),
    GoRoute(
      path: '/meal/:id',
      builder: (_, state) => RecipeDetailScreen(recipeId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/ai',          builder: (_, _) => const AiScreen()),
    GoRoute(path: '/ai-settings', builder: (_, _) => const AiSettingsScreen()),
    GoRoute(path: '/progress',    builder: (_, _) => const ProgressScreen()),
  ],
);

class BiteBuddyApp extends StatelessWidget {
  const BiteBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BiteBuddy',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
