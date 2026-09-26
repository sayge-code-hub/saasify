import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_badges.dart';

/// Shared column widths so header labels sit above cell content.
abstract final class TicketListColumns {
  static const double checkbox = 40;
  static const double id = 100;
  static const double priority = 120;
  static const double status = 120;
  static const double assignee = 128;
}

/// Very light vertical rule between ticket-list columns.
class TicketListColumnDivider extends StatelessWidget {
  const TicketListColumnDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: SizedBox(
        width: 1,
        height: 28,
        child: ColoredBox(color: AppColors.borderFaint),
      ),
    );
  }
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
    final cellStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.ink,
      fontWeight: FontWeight.w400,
    );

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
              const TicketListColumnDivider(),
              SizedBox(
                width: TicketListColumns.id,
                child: Text(ticket.id, style: cellStyle),
              ),
              const TicketListColumnDivider(),
              Expanded(
                child: Text(
                  ticket.subject,
                  style: cellStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const TicketListColumnDivider(),
              SizedBox(
                width: TicketListColumns.priority,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TicketPriorityBadge(priority: ticket.priority),
                ),
              ),
              const TicketListColumnDivider(),
              SizedBox(
                width: TicketListColumns.status,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TicketStatusBadge(status: ticket.status),
                ),
              ),
              const TicketListColumnDivider(),
              SizedBox(
                width: TicketListColumns.assignee,
                child: Text(
                  ticket.assigneeName ?? 'Unassigned',
                  style: cellStyle,
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
    final cellStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.ink,
      fontWeight: FontWeight.w400,
    );

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
                        Text(ticket.id, style: cellStyle),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          ticket.subject,
                          style: cellStyle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TicketPriorityBadge(priority: ticket.priority),
                  TicketStatusBadge(status: ticket.status),
                  Text(
                    ticket.assigneeName ?? 'Unassigned',
                    style: cellStyle,
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
