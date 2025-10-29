import 'package:flutter/material.dart';

class AppColors {
  // 🌸 Brand Identity Colors — Elegant Lavender Theme
  static const primary = Color(0xFF8A7FF0); // Main lavender shade
  static const secondary = Color(0xFF6C63FF); // Deeper violet-blue accent

  // 🌈 Support Colors
  static const accent = Color(0xFFFFB6C1); // Soft pink accent
  static const error = Color(0xFFE57373); // Gentle error tone (not too harsh)

  // 🧱 Surfaces & Backgrounds
  static const background = Color(0xFFF8F6FF); // Very light lavender for base background
  static const surface = Color(0xFFFFFFFF); // Card and modal background

  // 📝 Text Colors
  static const textPrimary = Color(0xFF2E2E3A); // Dark lavender-gray for readability
  static const textSecondary = Color(0xFF7A7A8C); // Muted grayish-purple tone

  // 🌤️ Gradient Shades — Lavender inspired gradients
  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF8A7FF0), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBackground = LinearGradient(
    colors: [Color(0xFFF8F6FF), Color(0xFFEDE9FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 🕶️ Shadows & Dividers
  static const shadow = Color(0x22000000); // Light transparent shadow for cards
  static const divider = Color(0xFFD9D5E3); // Soft lavender-gray divider
}
