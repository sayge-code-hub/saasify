import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography for Saasify.
///
/// Fonts are loaded via `web/index.html` (no runtime `google_fonts` fetch),
/// which keeps Flutter web startups reliable in restricted networks.
abstract final class AppTypography {
  static const String displayFamily = 'Fraunces';
  static const String bodyFamily = 'Source Sans 3';

  static TextTheme textTheme([TextTheme? base]) {
    final body = (base ?? ThemeData(useMaterial3: true).textTheme).apply(
      fontFamily: bodyFamily,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    TextStyle display(TextStyle? style) => (style ?? const TextStyle()).copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        );

    return body.copyWith(
      displayLarge: display(body.displayLarge).copyWith(letterSpacing: -0.5),
      displayMedium: display(body.displayMedium).copyWith(letterSpacing: -0.4),
      displaySmall: display(body.displaySmall),
      headlineLarge: display(body.headlineLarge).copyWith(letterSpacing: -0.3),
      headlineMedium: display(body.headlineMedium),
      headlineSmall: display(body.headlineSmall),
      titleLarge: body.titleLarge?.copyWith(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleSmall: body.titleSmall?.copyWith(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        fontFamily: bodyFamily,
        color: AppColors.ink,
        height: 1.5,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontFamily: bodyFamily,
        color: AppColors.inkSecondary,
        height: 1.5,
      ),
      bodySmall: body.bodySmall?.copyWith(
        fontFamily: bodyFamily,
        color: AppColors.inkTertiary,
        height: 1.4,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        color: AppColors.inkSecondary,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontFamily: bodyFamily,
        fontWeight: FontWeight.w600,
        color: AppColors.inkTertiary,
      ),
    );
  }
}
