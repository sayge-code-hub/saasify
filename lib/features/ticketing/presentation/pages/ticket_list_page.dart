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
  String _sortId = 'updated';

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

  Future<void> _pickExport(List<Ticket> tickets) async {
    final format = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_view_outlined),
                title: const Text('Excel'),
                subtitle: const Text('Spreadsheet (.xlsx)'),
                onTap: () => Navigator.of(context).pop('excel'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('PDF'),
                subtitle: const Text('Document (.pdf)'),
                onTap: () => Navigator.of(context).pop('pdf'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
    if (format == null || !mounted) return;
    final label = format == 'excel' ? 'Excel' : 'PDF';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported ${tickets.length} ticket${tickets.length == 1 ? '' : 's'} '
          'as $label (mock download).',
        ),
      ),
    );
  }

  Future<void> _pickFilter(TicketListCubit cubit) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All priorities'),
                onTap: () => Navigator.of(context).pop('all'),
              ),
              ListTile(
                title: const Text('Urgent only'),
                onTap: () => Navigator.of(context).pop('urgent'),
              ),
              ListTile(
                title: const Text('High only'),
                onTap: () => Navigator.of(context).pop('high'),
              ),
              ListTile(
                title: const Text('Unassigned only'),
                onTap: () => Navigator.of(context).pop('unassigned'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case 'urgent':
        cubit.setPriorityFilter(TicketPriority.urgent);
      case 'high':
        cubit.setPriorityFilter(TicketPriority.high);
      case 'all':
        cubit.setPriorityFilter(null);
      case 'unassigned':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unassigned filter coming soon (mock).'),
          ),
        );
    }
  }

  Future<void> _pickSort() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Recently updated'),
                trailing: _sortId == 'updated'
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop('updated'),
              ),
              ListTile(
                title: const Text('Priority'),
                trailing: _sortId == 'priority'
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop('priority'),
              ),
              ListTile(
                title: const Text('Ticket ID'),
                trailing: _sortId == 'id'
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop('id'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
    if (choice == null || !mounted) return;
    setState(() => _sortId = choice);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sorted by $choice (mock).')),
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

  List<Ticket> _sorted(List<Ticket> tickets) {
    final list = [...tickets];
    switch (_sortId) {
      case 'priority':
        list.sort(
          (a, b) => b.priority.index.compareTo(a.priority.index),
        );
      case 'id':
        list.sort((a, b) => b.id.compareTo(a.id));
      case 'updated':
      default:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return list;
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
        final tickets = _sorted(state.visible);
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
                      hasTickets: tickets.isNotEmpty,
                      selectedCount: selectedCount,
                      onExport: () => _pickExport(_exportTargets(state)),
                      onEmail: () => _emailTickets(_exportTargets(state)),
                      onFilter: () => _pickFilter(cubit),
                      onSort: _pickSort,
                      onDelete: () => _confirmDelete(cubit, selectedCount),
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
                              _ListHeader(
                                allSelected: state.allVisibleSelected,
                                partiallySelected: selectedCount > 0 &&
                                    !state.allVisibleSelected,
                                onSelectAllChanged: (value) {
                                  if (value == true) {
                                    cubit.selectAllVisible();
                                  } else {
                                    cubit.clearSelection();
                                  }
                                },
                                showColumnLabels: !compact,
                              ),
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
  const _ListHeader({
    required this.allSelected,
    required this.partiallySelected,
    required this.onSelectAllChanged,
    required this.showColumnLabels,
  });

  final bool allSelected;
  final bool partiallySelected;
  final ValueChanged<bool?> onSelectAllChanged;
  final bool showColumnLabels;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.inkTertiary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        );

    final selectValue = allSelected
        ? true
        : partiallySelected
            ? null
            : false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: TicketListColumns.checkbox,
            child: Checkbox(
              tristate: true,
              value: selectValue,
              onChanged: onSelectAllChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          if (showColumnLabels) ...[
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
          ] else
            Expanded(
              child: Text(
                allSelected ? 'Deselect all' : 'Select all',
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}

class _ListToolbar extends StatelessWidget {
  const _ListToolbar({
    required this.hasTickets,
    required this.selectedCount,
    required this.onExport,
    required this.onEmail,
    required this.onFilter,
    required this.onSort,
    required this.onDelete,
  });

  final bool hasTickets;
  final int selectedCount;
  final VoidCallback onExport;
  final VoidCallback onEmail;
  final VoidCallback onFilter;
  final VoidCallback onSort;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (selectedCount > 0) ...[
          Text(
            '$selectedCount selected',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.inkSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
          ),
        ],
        const Spacer(),
        _ToolbarButton(
          icon: Icons.ios_share_outlined,
          label: 'Export',
          onPressed: hasTickets ? onExport : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _ToolbarButton(
          icon: Icons.mail_outline,
          label: 'Email',
          onPressed: hasTickets ? onEmail : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _ToolbarButton(
          icon: Icons.filter_list,
          label: 'Filter',
          onPressed: onFilter,
        ),
        const SizedBox(width: AppSpacing.xs),
        _ToolbarButton(
          icon: Icons.sort,
          label: 'Sort',
          onPressed: onSort,
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
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border),
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
