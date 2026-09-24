import 'package:flutter/material.dart';

import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_page.dart';

/// Foundation home placeholder — replace when product specs arrive.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.canvas, AppColors.canvasTint],
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppConstants.appTagline,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Foundation ready. Share product requirements next — '
                  'features will be implemented against specs under /specs.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Project structure', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'BLoC · clean feature modules · shared widgets · '
            'responsive shell · agent/spec guardrails.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
