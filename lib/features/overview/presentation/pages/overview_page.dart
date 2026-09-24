import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_badges.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        final open = state.countWhere((t) => t.status == TicketStatus.open);
        final pending =
            state.countWhere((t) => t.status == TicketStatus.pending);
        final inProgress =
            state.countWhere((t) => t.status == TicketStatus.inProgress);
        final urgent = state.tickets
            .where(
              (t) =>
                  t.priority == TicketPriority.urgent &&
                  t.status != TicketStatus.closed &&
                  t.status != TicketStatus.resolved,
            )
            .toList();

        return AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Support pulse across the workspace.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _StatTile(
                    label: 'Open',
                    value: '$open',
                    color: const Color(0xFF075985),
                  ),
                  _StatTile(
                    label: 'In progress',
                    value: '$inProgress',
                    color: AppColors.accent,
                  ),
                  _StatTile(
                    label: 'Pending',
                    value: '$pending',
                    color: AppColors.warning,
                  ),
                  _StatTile(
                    label: 'Urgent active',
                    value: '${urgent.length}',
                    color: AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Needs attention',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  AppButton(
                    label: 'Open ticketing',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.go('/ticketing'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < urgent.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(urgent[i].subject),
                          subtitle: Text(
                            '${urgent[i].id} · ${urgent[i].customerName}',
                          ),
                          trailing: TicketPriorityBadge(
                            priority: urgent[i].priority,
                          ),
                          onTap: () => context.go(
                            '/ticketing/tickets/${urgent[i].id}',
                          ),
                        ),
                      ),
                    ],
                    if (urgent.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Text('No urgent tickets right now.'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(color: color),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
