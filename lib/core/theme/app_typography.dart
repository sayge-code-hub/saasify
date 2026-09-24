import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography built from brand fonts. Consume via [ThemeData.textTheme].
abstract final class AppTypography {
  static TextTheme textTheme() {
    final display = GoogleFonts.frauncesTextTheme();
    final body = GoogleFonts.sourceSans3TextTheme();

    return body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        letterSpacing: -0.5,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        letterSpacing: -0.4,
      ),
      displaySmall: display.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        letterSpacing: -0.3,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleSmall: body.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: AppColors.ink, height: 1.5),
      bodyMedium: body.bodyMedium?.copyWith(
        color: AppColors.inkSecondary,
        height: 1.5,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: AppColors.inkTertiary,
        height: 1.4,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.inkSecondary,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.inkTertiary,
      ),
    );
  }
}
