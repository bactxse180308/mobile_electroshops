import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTextStyles {
  static const h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.secondary);
  static const h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.secondary);
  static const h3 = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.secondary);
  static const body = TextStyle(fontSize: 14, color: AppColors.secondary);
  static const caption = TextStyle(fontSize: 11, color: AppColors.mutedForeground);
  static const price = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary);
  static const priceOld = TextStyle(
    fontSize: 12,
    decoration: TextDecoration.lineThrough,
    color: AppColors.mutedForeground,
  );
}

class AppShadows {
  static const card = [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))];
  static const lift = [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4))];
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.background,
      error: AppColors.destructive,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.secondary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 0),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.background,
    ),
  );
}
