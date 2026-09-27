import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_list_items.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

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
    final format = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _ExportFormatDialog(),
    );
    if (format == null || !mounted) return;
    final label = switch (format) {
      'excel' => 'Excel',
      'pdf' => 'PDF',
      'json' => 'Raw JSON',
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
        final selectedCount = state.selectedIds.length;

        return ColoredBox(
          color: AppColors.canvas,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      AppSpacing.pageContentTop,
                      horizontal,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'All Tickets',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ListToolbar(
                          compact: compact,
                          searchController: _searchController,
                          onSearchChanged: cubit.setQuery,
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
            ),
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
          fontWeight: FontWeight.w400,
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
            const TicketListColumnDivider(),
            SizedBox(
              width: TicketListColumns.id,
              child: Text('ID', style: style),
            ),
            const TicketListColumnDivider(),
            Expanded(child: Text('TICKET', style: style)),
            const TicketListColumnDivider(),
            SizedBox(
              width: TicketListColumns.priority,
              child: Text('PRIORITY', style: style),
            ),
            const TicketListColumnDivider(),
            SizedBox(
              width: TicketListColumns.status,
              child: Text('STATUS', style: style),
            ),
            const TicketListColumnDivider(),
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
    required this.compact,
    required this.searchController,
    required this.onSearchChanged,
    required this.hasTickets,
    required this.selectedCount,
    required this.onExport,
    required this.onEmail,
    required this.onFilter,
    required this.onSort,
    required this.onDelete,
  });

  final bool compact;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool hasTickets;
  final int selectedCount;
  final VoidCallback onExport;
  final VoidCallback onEmail;
  final VoidCallback onFilter;
  final VoidCallback onSort;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedCount > 0) ...[
          Text(
            '$selectedCount selected',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.inkSecondary,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(width: AppSpacing.xs),
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
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

    final search = _TicketSearchField(
      controller: searchController,
      onChanged: onSearchChanged,
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: actions,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: search),
        const SizedBox(width: AppSpacing.md),
        actions,
      ],
    );
  }
}

class _TicketSearchField extends StatelessWidget {
  const _TicketSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.ink,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.2,
    );
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.inkTertiary,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.2,
    );

    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: textStyle,
        cursorColor: AppColors.accent,
        cursorHeight: 14,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          hintText: 'Search by id, subject, or customer',
          hintStyle: hintStyle,
          prefixIcon: const Icon(Icons.search, size: 18),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(color: AppColors.accent, width: 1),
          ),
        ),
      ),
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
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: AppColors.ink),
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 0,
        ),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}

class _ExportFormatDialog extends StatelessWidget {
  const _ExportFormatDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Export',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose a format for the current ticket list.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ExportFormatOption(
                icon: Icons.table_view_outlined,
                title: 'Excel',
                subtitle: 'Spreadsheet (.xlsx)',
                onTap: () => Navigator.of(context).pop('excel'),
              ),
              const SizedBox(height: AppSpacing.xs),
              _ExportFormatOption(
                icon: Icons.picture_as_pdf_outlined,
                title: 'PDF',
                subtitle: 'Document (.pdf)',
                onTap: () => Navigator.of(context).pop('pdf'),
              ),
              const SizedBox(height: AppSpacing.xs),
              _ExportFormatOption(
                icon: Icons.data_object_outlined,
                title: 'Raw JSON',
                subtitle: 'Structured data (.json)',
                onTap: () => Navigator.of(context).pop('json'),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportFormatOption extends StatelessWidget {
  const _ExportFormatOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        hoverColor: AppColors.surfaceMuted,
        splashColor: AppColors.accentMuted.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: AppColors.inkSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.inkTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
