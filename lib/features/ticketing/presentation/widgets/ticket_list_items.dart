import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_badges.dart';

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
      color: selected ? AppColors.accentMuted : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: selected,
                  onChanged: onSelectedChanged,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(
                width: 88,
                child: Text(
                  ticket.id,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ticket.customerName} · ${ticket.customerEmail}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.inkTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TicketPriorityBadge(priority: ticket.priority),
              const SizedBox(width: AppSpacing.xs),
              TicketStatusBadge(status: ticket.status),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 110,
                child: Text(
                  ticket.assigneeName ?? 'Unassigned',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                  maxLines: 1,
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
      color: selected ? AppColors.accentMuted : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: onSelectedChanged,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    ticket.id,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TicketStatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ticket.subject,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ticket.customerName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  TicketPriorityBadge(priority: ticket.priority),
                  const Spacer(),
                  Text(
                    ticket.assigneeName ?? 'Unassigned',
                    style: theme.textTheme.bodySmall,
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
