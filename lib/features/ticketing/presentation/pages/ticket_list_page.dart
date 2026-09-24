import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_list_items.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({this.routeFilter = 'all', super.key});

  /// `all` | `open` | `pending` | `resolved`
  final String routeFilter;

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<TicketListCubit>().state.query,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TicketListCubit>().applyRouteFilter(widget.routeFilter);
    });
  }

  @override
  void didUpdateWidget(covariant TicketListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeFilter != widget.routeFilter) {
      context.read<TicketListCubit>().applyRouteFilter(widget.routeFilter);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = context.isCompact;

    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        final tickets = state.visible;
        final title = switch (widget.routeFilter) {
          'open' => 'Open tickets',
          'pending' => 'Pending tickets',
          'resolved' => 'Resolved tickets',
          _ => 'All tickets',
        };

        return AppPage(
          scrollable: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Triage and resolve customer support requests.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _searchController,
                label: 'Search',
                hint: 'Search by id, subject, or customer',
                prefixIcon: const Icon(Icons.search),
                onChanged: context.read<TicketListCubit>().setQuery,
              ),
              const SizedBox(height: AppSpacing.md),
              _FilterBar(
                status: state.statusFilter,
                priority: state.priorityFilter,
                routeLocked: widget.routeFilter != 'all',
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: tickets.isEmpty
                      ? const AppEmptyState(
                          title: 'No tickets match',
                          message: 'Try clearing search or filters.',
                          icon: Icons.confirmation_number_outlined,
                        )
                      : ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          child: ListView.separated(
                            itemCount: tickets.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final ticket = tickets[index];
                              void open() => context.go(
                                    '/ticketing/tickets/${ticket.id}',
                                  );
                              if (compact) {
                                return TicketListCard(
                                  ticket: ticket,
                                  onTap: open,
                                );
                              }
                              return TicketListRow(
                                ticket: ticket,
                                onTap: open,
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.status,
    required this.priority,
    required this.routeLocked,
  });

  final TicketStatus? status;
  final TicketPriority? priority;
  final bool routeLocked;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TicketListCubit>();

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!routeLocked) ...[
          Text('Status', style: Theme.of(context).textTheme.labelMedium),
          ChoiceChip(
            label: const Text('Any'),
            selected: status == null,
            onSelected: (_) => cubit.setStatusFilter(null),
          ),
          for (final value in TicketStatus.values)
            ChoiceChip(
              label: Text(value.label),
              selected: status == value,
              onSelected: (_) => cubit.setStatusFilter(value),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text('Priority', style: Theme.of(context).textTheme.labelMedium),
        ChoiceChip(
          label: const Text('Any'),
          selected: priority == null,
          onSelected: (_) => cubit.setPriorityFilter(null),
        ),
        for (final value in TicketPriority.values)
          ChoiceChip(
            label: Text(value.label),
            selected: priority == value,
            onSelected: (_) => cubit.setPriorityFilter(value),
          ),
      ],
    );
  }
}
