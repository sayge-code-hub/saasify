import 'package:flutter/material.dart';

/// Semantic color tokens for Saasify. Prefer [ThemeData.colorScheme] in UI.
abstract final class AppColors {
  static const Color canvas = Color(0xFFF3F6F8);
  static const Color canvasTint = Color(0xFFE8EEF2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7FAFB);

  static const Color ink = Color(0xFF0F1C24);
  static const Color inkSecondary = Color(0xFF4A5C68);
  static const Color inkTertiary = Color(0xFF7A8B96);
  static const Color border = Color(0xFFD5DEE5);

  static const Color accent = Color(0xFF0F766E);
  static const Color accentHover = Color(0xFF0D9488);
  static const Color accentMuted = Color(0xFFCCFBF1);

  static const Color danger = Color(0xFFB42318);
  static const Color dangerMuted = Color(0xFFFEE4E2);
  static const Color success = Color(0xFF027A48);
  static const Color successMuted = Color(0xFFD1FADF);
  static const Color warning = Color(0xFFB54708);
  static const Color warningMuted = Color(0xFFFEF0C7);
}
