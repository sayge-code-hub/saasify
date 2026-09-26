import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_list_items.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({this.routeFilter = 'all', super.key});

  /// `all` | `open` | `pending` | `resolved` | `priority`
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

  Future<void> _confirmDelete(TicketListCubit cubit, int count) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete tickets'),
        content: Text(
          'Delete $count selected ticket${count == 1 ? '' : 's'}? '
          'This cannot be undone in the mock queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      cubit.deleteSelected();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleted $count ticket${count == 1 ? '' : 's'}.',
          ),
        ),
      );
    }
  }

  Future<void> _emailTickets(List<Ticket> tickets) async {
    final emailController = TextEditingController();
    final sent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email tickets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Send ${tickets.length} ticket${tickets.length == 1 ? '' : 's'} '
              'as a summary to:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'name@company.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) return;
              Navigator.of(context).pop(true);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
    final email = emailController.text.trim();
    emailController.dispose();
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Queued ${tickets.length} ticket${tickets.length == 1 ? '' : 's'} '
            'to $email (mock).',
          ),
        ),
      );
    }
  }

  void _export(String format, List<Ticket> tickets) {
    final label = switch (format) {
      'excel' => 'Excel',
      'pdf' => 'PDF',
      _ => format,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported ${tickets.length} ticket${tickets.length == 1 ? '' : 's'} '
          'as $label (mock download).',
        ),
      ),
    );
  }

  List<Ticket> _exportTargets(TicketListState state) {
    if (state.hasSelection) {
      return state.visible
          .where((t) => state.selectedIds.contains(t.id))
          .toList();
    }
    return state.visible;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = context.isCompact;
    final horizontal = compact
        ? AppSpacing.pagePaddingCompact
        : AppSpacing.pagePaddingExpanded;

    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        final cubit = context.read<TicketListCubit>();
        final tickets = state.visible;
        final title = switch (widget.routeFilter) {
          'open' => 'Open Tickets',
          'pending' => 'Pending Tickets',
          'resolved' => 'Resolved Tickets',
          'priority' => 'Priority Tickets',
          _ => 'All Tickets',
        };
        final selectedCount = state.selectedIds.length;

        return ColoredBox(
          color: AppColors.canvas,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  AppSpacing.lg,
                  horizontal,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _searchController,
                      hint: 'Search by id, subject, or customer',
                      prefixIcon: const Icon(Icons.search),
                      onChanged: cubit.setQuery,
                    ),
                    if (widget.routeFilter == 'priority') ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Showing urgent and high priority tickets.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.inkTertiary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _ListToolbar(
                      compact: compact,
                      allSelected: state.allVisibleSelected,
                      hasTickets: tickets.isNotEmpty,
                      selectedCount: selectedCount,
                      onSelectAll: cubit.selectAllVisible,
                      onDeselectAll: cubit.clearSelection,
                      onExportExcel: () =>
                          _export('excel', _exportTargets(state)),
                      onExportPdf: () =>
                          _export('pdf', _exportTargets(state)),
                      onEmail: () => _emailTickets(_exportTargets(state)),
                      onDelete: selectedCount == 0
                          ? null
                          : () => _confirmDelete(cubit, selectedCount),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    0,
                    horizontal,
                    AppSpacing.lg,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: tickets.isEmpty
                        ? const AppEmptyState(
                            title: 'No tickets match',
                            message: 'Try clearing search or filters.',
                            icon: Icons.confirmation_number_outlined,
                          )
                        : Column(
                            children: [
                              if (!compact) const _ListHeader(),
                              const Divider(height: 1),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: tickets.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final ticket = tickets[index];
                                    final selected =
                                        state.isSelected(ticket.id);
                                    void open() => context.go(
                                          '/ticketing/tickets/${ticket.id}',
                                        );
                                    void toggle(bool? value) {
                                      if (value == null) return;
                                      cubit.toggleSelected(ticket.id);
                                    }

                                    if (compact) {
                                      return TicketListCard(
                                        ticket: ticket,
                                        selected: selected,
                                        onSelectedChanged: toggle,
                                        onTap: open,
                                      );
                                    }
                                    return TicketListRow(
                                      ticket: ticket,
                                      selected: selected,
                                      onSelectedChanged: toggle,
                                      onTap: open,
                                    );
                                  },
                                ),
                              ),
                            ],
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

class _ListHeader extends StatelessWidget {
  const _ListHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.inkTertiary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: TicketListColumns.checkbox),
          SizedBox(
            width: TicketListColumns.id,
            child: Text('ID', style: style),
          ),
          Expanded(child: Text('TICKET', style: style)),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: TicketListColumns.priority,
            child: Text('PRIORITY', style: style),
          ),
          SizedBox(
            width: TicketListColumns.status,
            child: Text('STATUS', style: style),
          ),
          SizedBox(
            width: TicketListColumns.assignee,
            child: Text('ASSIGNEE', style: style),
          ),
        ],
      ),
    );
  }
}

class _ListToolbar extends StatelessWidget {
  const _ListToolbar({
    required this.compact,
    required this.allSelected,
    required this.hasTickets,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onExportExcel,
    required this.onExportPdf,
    required this.onEmail,
    required this.onDelete,
  });

  final bool compact;
  final bool allSelected;
  final bool hasTickets;
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;
  final VoidCallback onEmail;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ToolbarButton(
          icon: Icons.table_view_outlined,
          label: compact ? 'Excel' : 'Export Excel',
          onPressed: hasTickets ? onExportExcel : null,
        ),
        _ToolbarButton(
          icon: Icons.picture_as_pdf_outlined,
          label: compact ? 'PDF' : 'Export PDF',
          onPressed: hasTickets ? onExportPdf : null,
        ),
        _ToolbarButton(
          icon: Icons.mail_outline,
          label: 'Email',
          onPressed: hasTickets ? onEmail : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _ToolbarButton(
          icon: Icons.select_all,
          label: 'Select all',
          onPressed: hasTickets ? onSelectAll : null,
        ),
        _ToolbarButton(
          icon: Icons.deselect,
          label: 'Deselect all',
          onPressed: selectedCount > 0 ? onDeselectAll : null,
        ),
        if (selectedCount > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              '$selectedCount selected',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.accentHover,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _ToolbarButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            danger: true,
            onPressed: onDelete,
          ),
        ],
        if (allSelected && hasTickets)
          Text(
            'All visible selected',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkTertiary,
            ),
          ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: onPressed == null ? null : color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: danger ? AppColors.danger.withValues(alpha: 0.4) : AppColors.border,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}
