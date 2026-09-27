import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

/// Signed-in user profile summary.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = switch (context.watch<AuthCubit>().state) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            title: 'Profile',
            subtitle: 'Your account details for this workspace.',
          ),
          const SizedBox(height: AppSpacing.lg),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accentMuted,
                    foregroundColor: AppColors.accentHover,
                    child: Text(
                      (user?.name.isNotEmpty ?? false)
                          ? user!.name[0].toUpperCase()
                          : 'A',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.accentHover,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          user?.name ?? 'Agent',
                          key: const ValueKey('profile-name'),
                          variant: AppTextVariant.sectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          user?.email ?? '',
                          key: const ValueKey('profile-email'),
                          variant: AppTextVariant.pageSubtitle,
                        ),
                        if (user?.role != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          AppText(
                            user!.role,
                            variant: AppTextVariant.meta,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
