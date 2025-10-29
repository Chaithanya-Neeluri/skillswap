import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 🌟 Headings — Elegant, rounded, modern
  static const heading = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.3,
    fontFamily: 'Poppins', // clean modern font
  );

  // ✨ Subheadings — slightly smaller, semi-bold
  static const subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
    height: 1.35,
    fontFamily: 'Poppins',
  );

  // 📄 Body — clear and comfortable for reading
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: 'Inter', // softer, readable text
  );

  // 💬 Caption — secondary info, muted but visible
  static const caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.1,
    fontFamily: 'Inter',
  );

  // 🪶 Small hint text (for fields, buttons, etc.)
  static const hint = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );

  // 💜 Accent Text (for highlighting words in lavender tone)
  static const accent = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: 'Poppins',
  );

  // 🩵 Button text — bold and elegant
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
    fontFamily: 'Poppins',
  );
}
