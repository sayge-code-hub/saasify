import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/assets/domain/pm_plan.dart';

class PmStatusChip extends StatelessWidget {
  const PmStatusChip({required this.status, super.key});

  final PmPlanStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      PmPlanStatus.overdue => (AppColors.dangerMuted, AppColors.danger),
      PmPlanStatus.dueSoon => (AppColors.warningMuted, AppColors.warning),
      PmPlanStatus.scheduled => (AppColors.successMuted, AppColors.success),
      PmPlanStatus.completed => (AppColors.surfaceMuted, AppColors.inkTertiary),
      PmPlanStatus.paused => (AppColors.accentMuted, AppColors.accentHover),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

String formatPmDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatPmDuration(Duration duration) {
  if (duration.inMinutes < 60) return '${duration.inMinutes} min';
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (minutes == 0) return '$hours h';
  return '$hours h $minutes min';
}
