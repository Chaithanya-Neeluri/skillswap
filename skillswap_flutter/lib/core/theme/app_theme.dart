import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

final ThemeData appTheme = ThemeData(
  // 🌸 Core Brand Colors
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
  ),

  // 🧭 AppBar Styling
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 4,
    shadowColor: AppColors.shadow,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: AppTextStyles.subheading,
    centerTitle: true,
  ),

  // 🩵 Input Fields (TextFields)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    hintStyle: AppTextStyles.hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  ),

  // 🪄 Buttons — Rounded, Elevated Look
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shadowColor: AppColors.shadow,
      textStyle: AppTextStyles.button,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      minimumSize: const Size(double.infinity, 52),
    ),
  ),

  // 🌿 Text Buttons
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.secondary,
      textStyle: AppTextStyles.accent.copyWith(
        fontSize: 15,
        decoration: TextDecoration.underline,
      ),
    ),
  ),

  // 🧱 Card + Surface Components
  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    shadowColor: AppColors.shadow,
  ),

  // 🩶 Divider
  dividerColor: AppColors.divider,
  dividerTheme: const DividerThemeData(thickness: 1),

  // 💬 Snackbar — modern rounded edges
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.primary,
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    behavior: SnackBarBehavior.floating,
  ),

  // 🕶️ Visual Density & Touch Optimization
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
