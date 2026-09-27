import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/theme/app_typography.dart';

/// Semantic text styles reused across the app — prefer this over ad-hoc
/// [TextStyle] / [ThemeData.textTheme] overrides in feature pages.
enum AppTextVariant {
  /// Screen-level title outside cards (Dashboard, Config, All Tickets…).
  pageTitle,

  /// One-line support under a page title.
  pageSubtitle,

  /// Card / section title inside a content block.
  sectionTitle,

  /// Support line under a section title.
  sectionSubtitle,

  /// Primary body copy.
  body,

  /// Field labels above inputs.
  label,

  /// Quiet metadata (counts, timestamps, table headers).
  meta,
}

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    required this.variant,
    super.key,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.color,
  });

  final String data;
  final AppTextVariant variant;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final Color? color;

  static TextStyle styleFor(
    BuildContext context,
    AppTextVariant variant, {
    Color? color,
  }) {
    final theme = Theme.of(context).textTheme;
    final base = switch (variant) {
      AppTextVariant.pageTitle => theme.headlineSmall?.copyWith(
          fontFamily: AppTypography.bodyFamily,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
          letterSpacing: -0.2,
          height: 1.2,
        ),
      AppTextVariant.pageSubtitle => theme.bodyMedium?.copyWith(
          fontFamily: AppTypography.bodyFamily,
          fontWeight: FontWeight.w400,
          color: AppColors.inkSecondary,
          height: 1.4,
        ),
      AppTextVariant.sectionTitle => theme.titleMedium?.copyWith(
          fontFamily: AppTypography.bodyFamily,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
          height: 1.25,
        ),
      AppTextVariant.sectionSubtitle => theme.bodySmall?.copyWith(
          fontFamily: AppTypography.bodyFamily,
          fontWeight: FontWeight.w400,
          color: AppColors.inkSecondary,
          height: 1.4,
        ),
      AppTextVariant.body => theme.bodyMedium?.copyWith(
          fontFamily: AppTypography.bodyFamily,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
          height: 1.45,
        ),
      AppTextVariant.label => theme.labelLarge?.copyWith(
          fontFamily: AppTypography.bodyFamily,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
          height: 1.2,
        ),
      AppTextVariant.meta => theme.labelMedium?.copyWith(
          fontFamily: AppTypography.bodyFamily,
          fontWeight: FontWeight.w400,
          color: AppColors.inkTertiary,
          height: 1.3,
        ),
    };
    if (color == null) return base ?? const TextStyle();
    return (base ?? const TextStyle()).copyWith(color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: styleFor(context, variant, color: color),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

/// Standard page chrome: title + optional subtitle, matching every admin screen.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, variant: AppTextVariant.pageTitle),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppText(subtitle!, variant: AppTextVariant.pageSubtitle),
        ],
      ],
    );

    if (trailing == null) return titleBlock;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: AppSpacing.sm),
        trailing!,
      ],
    );
  }
}
