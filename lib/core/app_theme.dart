import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.forestGreen,
      primary: AppColors.forestGreen,
      secondary: AppColors.orange,
      surface: AppColors.cream,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.forestGreen,
      unselectedItemColor: AppColors.textMuted,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.forestGreen, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textDark),
      bodySmall: TextStyle(color: AppColors.textMuted),
    ),
  );
}
