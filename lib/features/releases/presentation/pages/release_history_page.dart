import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/features/releases/data/release_notes.dart';

/// Lists deployed versions and their changelog entries.
class ReleaseHistoryPage extends StatelessWidget {
  const ReleaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final releases = ReleaseNotes.all;

    return SelectionArea(
      child: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.go('/ticketing'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppPageHeader(
              title: 'Release history',
              subtitle:
                  'Versions deployed for ${AppConstants.appName}, including features, '
                  'improvements, and bug fixes. Current: ${AppConstants.appVersionLabel}.',
            ),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < releases.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              _ReleaseCard(
                release: releases[i],
                isCurrent: releases[i].version == ReleaseNotes.currentVersion,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({required this.release, required this.isCurrent});

  final AppRelease release;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isCurrent ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText(
                  'v${release.version}',
                  variant: AppTextVariant.sectionTitle,
                ),
                if (isCurrent) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentMuted,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      'Current',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.accentHover,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  _formatDate(release.releasedAt),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.inkTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              release.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final change in release.changes) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChangeBadge(type: change.type),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        change.summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.ink,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final mo = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '${value.year}-$mo-$d';
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.type});

  final ReleaseChangeType type;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      ReleaseChangeType.feature => (
        AppColors.accentMuted,
        AppColors.accentHover,
      ),
      ReleaseChangeType.improvement => (
        AppColors.successMuted,
        AppColors.success,
      ),
      ReleaseChangeType.bugfix => (AppColors.warningMuted, AppColors.warning),
    };

    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        switch (type) {
          ReleaseChangeType.feature => 'Feature',
          ReleaseChangeType.improvement => 'Improvement',
          ReleaseChangeType.bugfix => 'Bug fix',
        },
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 10),
      ),
    );
  }
}
