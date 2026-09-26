import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_badges.dart';

/// Shared column widths so header labels sit above cell content.
abstract final class TicketListColumns {
  static const double checkbox = 40;
  static const double id = 96;
  static const double priority = 104;
  static const double status = 112;
  static const double assignee = 120;
}

class TicketListRow extends StatelessWidget {
  const TicketListRow({
    required this.ticket,
    required this.onTap,
    required this.selected,
    required this.onSelectedChanged,
    super.key,
  });

  final Ticket ticket;
  final VoidCallback onTap;
  final bool selected;
  final ValueChanged<bool?> onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected ? AppColors.accentSoft : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: TicketListColumns.checkbox,
                child: Checkbox(
                  value: selected,
                  onChanged: onSelectedChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(
                width: TicketListColumns.id,
                child: Text(
                  ticket.id,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  ticket.subject,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: TicketListColumns.priority,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TicketPriorityBadge(priority: ticket.priority),
                ),
              ),
              SizedBox(
                width: TicketListColumns.status,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TicketStatusBadge(status: ticket.status),
                ),
              ),
              SizedBox(
                width: TicketListColumns.assignee,
                child: Text(
                  ticket.assigneeName ?? 'Unassigned',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketListCard extends StatelessWidget {
  const TicketListCard({
    required this.ticket,
    required this.onTap,
    required this.selected,
    required this.onSelectedChanged,
    super.key,
  });

  final Ticket ticket;
  final VoidCallback onTap;
  final bool selected;
  final ValueChanged<bool?> onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected ? AppColors.accentSoft : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: onSelectedChanged,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.id,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          ticket.subject,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  TicketPriorityBadge(priority: ticket.priority),
                  TicketStatusBadge(status: ticket.status),
                  Text(
                    ticket.assigneeName ?? 'Unassigned',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
