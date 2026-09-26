import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/ticketing/domain/ticket_config.dart';
import 'package:saasify/features/ticketing/domain/ticket_config_lists.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';

/// Full-screen editor for one configurable dropdown list.
class TicketConfigListPage extends StatefulWidget {
  const TicketConfigListPage({required this.kind, super.key});

  final TicketConfigListKind kind;

  @override
  State<TicketConfigListPage> createState() => _TicketConfigListPageState();
}

class _TicketConfigListPageState extends State<TicketConfigListPage> {
  late List<String> _draft;
  late List<String> _baseline;
  final _searchController = TextEditingController();
  String _query = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Draft is hydrated in didChangeDependencies once the cubit is available.
    _baseline = const [];
    _draft = const [];
  }

  bool _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    final config = context.read<TicketConfigCubit>().state;
    _baseline = List<String>.from(_valuesFor(config, widget.kind));
    _draft = List<String>.from(_baseline);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isDirty {
    if (_draft.length != _baseline.length) return true;
    for (var i = 0; i < _draft.length; i++) {
      if (_draft[i] != _baseline[i]) return true;
    }
    return false;
  }

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _draft;
    return _draft.where((item) => item.toLowerCase().contains(q)).toList();
  }

  static List<String> _valuesFor(TicketConfig config, TicketConfigListKind kind) {
    return switch (kind) {
      TicketConfigListKind.applications => config.applications,
      TicketConfigListKind.distributionLists => config.distributionLists,
      TicketConfigListKind.assignees => config.assignees,
      TicketConfigListKind.bugOptions => config.bugOptions,
    };
  }

  void _applyToCubit(TicketConfigCubit cubit) {
    switch (widget.kind) {
      case TicketConfigListKind.applications:
        cubit.setApplications(_draft);
      case TicketConfigListKind.distributionLists:
        cubit.setDistributionLists(_draft);
      case TicketConfigListKind.assignees:
        cubit.setAssignees(_draft);
      case TicketConfigListKind.bugOptions:
        cubit.setBugOptions(_draft);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. If you leave now, those edits will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _handleBack() async {
    final leave = await _confirmDiscard();
    if (!leave || !mounted) return;
    context.go('/ticketing/config');
  }

  Future<void> _save() async {
    if (!_isDirty) {
      context.go('/ticketing/config');
      return;
    }
    if (_draft.isEmpty && !widget.kind.allowEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keep at least one ${widget.kind.singular}.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save ${widget.kind.title.toLowerCase()}?'),
        content: Text(
          'Apply ${_draft.length} option${_draft.length == 1 ? '' : 's'} '
          'to Add Ticket and related screens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    _applyToCubit(context.read<TicketConfigCubit>());
    if (!mounted) return;
    context.go('/ticketing/config');
  }

  Future<void> _startAdd() async {
    final draftValue = await showDialog<String>(
      context: context,
      builder: (context) => _AddOptionDialog(
        title: widget.kind.addLabel,
        singular: widget.kind.singular,
      ),
    );
    if (draftValue == null || !mounted) return;

    if (_draft.any((item) => item.toLowerCase() == draftValue.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$draftValue" already exists.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${widget.kind.singular}?'),
        content: Text(
          'Add "$draftValue" to ${widget.kind.title.toLowerCase()}? '
          'You still need to save before this change is applied.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _draft = [..._draft, draftValue]);
  }

  Future<void> _confirmRemove(String value) async {
    if (_draft.length <= 1 && !widget.kind.allowEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keep at least one ${widget.kind.singular}.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${widget.kind.singular}?'),
        content: Text('Remove "$value" from this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _draft = _draft.where((item) => item != value).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('config-list-back'),
                onPressed: _handleBack,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: Text(
                  'Config',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.kind.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.kind.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: 'Save',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _searchController,
              hint: 'Search ${widget.kind.title.toLowerCase()}…',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                key: const ValueKey('config-list-add'),
                label: widget.kind.addLabel,
                icon: Icons.add,
                onPressed: _startAdd,
              ),
            ),
            if (_isDirty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Unsaved changes',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (filtered.isEmpty)
              SizedBox(
                height: 240,
                child: AppEmptyState(
                  title: _draft.isEmpty ? 'No options yet' : 'No matches',
                  message: _draft.isEmpty
                      ? 'Use ${widget.kind.addLabel} to create the first item.'
                      : 'Try a different search term.',
                  icon: Icons.inbox_outlined,
                  actionLabel: _draft.isEmpty ? widget.kind.addLabel : null,
                  onAction: _draft.isEmpty ? _startAdd : null,
                ),
              )
            else
              for (var i = 0; i < filtered.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                _OptionItemCard(
                  label: filtered[i],
                  onRemove: () => _confirmRemove(filtered[i]),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _OptionItemCard extends StatelessWidget {
  const _OptionItemCard({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Remove',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOptionDialog extends StatefulWidget {
  const _AddOptionDialog({
    required this.title,
    required this.singular,
  });

  final String title;
  final String singular;

  @override
  State<_AddOptionDialog> createState() => _AddOptionDialogState();
}

class _AddOptionDialogState extends State<_AddOptionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Name',
          hintText: 'Enter ${widget.singular} name',
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
