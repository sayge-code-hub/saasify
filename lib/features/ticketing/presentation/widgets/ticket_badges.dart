import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';

class TicketStatusBadge extends StatelessWidget {
  const TicketStatusBadge({required this.status, super.key});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      TicketStatus.open => (AppColors.accentMuted, AppColors.accentHover),
      TicketStatus.inProgress => (AppColors.surfaceMuted, AppColors.ink),
      TicketStatus.pending => (AppColors.warningMuted, AppColors.warning),
      TicketStatus.resolved => (AppColors.successMuted, AppColors.success),
      TicketStatus.closed => (AppColors.surfaceMuted, AppColors.inkSecondary),
    };

    return _TagChip(label: status.label, background: bg, foreground: fg);
  }
}

class TicketPriorityBadge extends StatelessWidget {
  const TicketPriorityBadge({required this.priority, super.key});

  final TicketPriority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (priority) {
      TicketPriority.low => (AppColors.surfaceMuted, AppColors.inkSecondary),
      TicketPriority.medium => (AppColors.accentMuted, AppColors.accentHover),
      TicketPriority.high => (AppColors.warningMuted, AppColors.warning),
      TicketPriority.urgent => (AppColors.dangerMuted, AppColors.danger),
    };

    return _TagChip(label: priority.label, background: bg, foreground: fg);
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
