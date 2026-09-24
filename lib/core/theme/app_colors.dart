import 'package:flutter/material.dart';

/// Semantic color tokens for Saasify. Prefer [ThemeData.colorScheme] in UI.
/// Palette: pure white · black · orange.
abstract final class AppColors {
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasTint = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFAFAFA);

  static const Color ink = Color(0xFF0A0A0A);
  static const Color inkSecondary = Color(0xFF404040);
  static const Color inkTertiary = Color(0xFF737373);
  static const Color border = Color(0xFFE5E5E5);

  static const Color accent = Color(0xFFFF6542);
  static const Color accentHover = Color(0xFFE85A3A);
  static const Color accentMuted = Color(0xFFFFF0EC);

  static const Color danger = Color(0xFFB42318);
  static const Color dangerMuted = Color(0xFFFEE4E2);
  static const Color success = Color(0xFF027A48);
  static const Color successMuted = Color(0xFFD1FADF);
  static const Color warning = Color(0xFFB54708);
  static const Color warningMuted = Color(0xFFFEF0C7);
}
