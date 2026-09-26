import 'package:flutter/material.dart';

/// Semantic color tokens for Saasify. Prefer [ThemeData.colorScheme] in UI.
/// Palette: light grey canvas · white surfaces · black ink · soft coral.
abstract final class AppColors {
  /// Page / shell background (matches dashboard).
  static const Color canvas = Color(0xFFFAFAFA);
  static const Color canvasTint = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFAFAFA);

  static const Color ink = Color(0xFF0A0A0A);
  static const Color inkSecondary = Color(0xFF404040);
  static const Color inkTertiary = Color(0xFF737373);
  static const Color border = Color(0xFFE8E8E8);

  /// Soft coral — easier on the eyes than a neon orange.
  static const Color accent = Color(0xFFE87A5C);
  static const Color accentHover = Color(0xFFD66A4E);
  static const Color accentDeep = Color(0xFFD45F42);
  static const Color accentLight = Color(0xFFFFB39A);
  static const Color accentMuted = Color(0xFFFFF1EC);
  static const Color accentSoft = Color(0xFFFFF8F5);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB39A), Color(0xFFE87A5C), Color(0xFFD45F42)],
    stops: [0.0, 0.55, 1.0],
  );

  static const Color danger = Color(0xFFB42318);
  static const Color dangerMuted = Color(0xFFFEE4E2);
  static const Color success = Color(0xFF027A48);
  static const Color successMuted = Color(0xFFD1FADF);
  static const Color warning = Color(0xFFB54708);
  static const Color warningMuted = Color(0xFFFEF0C7);
}
