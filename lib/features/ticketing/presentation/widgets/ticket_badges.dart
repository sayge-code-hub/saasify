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
      TicketStatus.open => (const Color(0xFFE0F2FE), const Color(0xFF075985)),
      TicketStatus.inProgress => (AppColors.accentMuted, AppColors.accent),
      TicketStatus.pending => (AppColors.warningMuted, AppColors.warning),
      TicketStatus.resolved => (AppColors.successMuted, AppColors.success),
      TicketStatus.closed => (AppColors.canvasTint, AppColors.inkSecondary),
    };

    return _Pill(label: status.label, background: bg, foreground: fg);
  }
}

class TicketPriorityBadge extends StatelessWidget {
  const TicketPriorityBadge({required this.priority, super.key});

  final TicketPriority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (priority) {
      TicketPriority.low => (AppColors.canvasTint, AppColors.inkSecondary),
      TicketPriority.medium => (const Color(0xFFE0F2FE), const Color(0xFF075985)),
      TicketPriority.high => (AppColors.warningMuted, AppColors.warning),
      TicketPriority.urgent => (AppColors.dangerMuted, AppColors.danger),
    };

    return _Pill(label: priority.label, background: bg, foreground: fg);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
