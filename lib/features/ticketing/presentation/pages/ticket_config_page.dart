import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_page.dart';

/// Placeholder ticketing configuration surface.
class TicketConfigPage extends StatelessWidget {
  const TicketConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Config',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Queue defaults and workflow preferences for ticketing.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _ConfigTile(
            title: 'Default assignee',
            subtitle: 'Unassigned — agents claim from the queue',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _ConfigTile(
            title: 'SLA target',
            subtitle: 'First response within 4 business hours',
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _ConfigTile(
            title: 'Priority routing',
            subtitle: 'Urgent and high surface in Priority Tickets',
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Editing these values will land in a later slice. Current focus is the admin UI.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
