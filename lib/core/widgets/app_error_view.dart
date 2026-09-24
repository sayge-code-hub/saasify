import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';

/// Standard error presentation with optional retry.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Try again',
                  onPressed: onRetry,
                  variant: AppButtonVariant.outlined,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
