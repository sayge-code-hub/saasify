import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/domain/ticket_config.dart';
import 'package:saasify/features/ticketing/domain/ticket_config_lists.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';

/// Config hub: searchable sections for dropdown lists + SLA targets.
class TicketConfigPage extends StatefulWidget {
  const TicketConfigPage({super.key});

  @override
  State<TicketConfigPage> createState() => _TicketConfigPageState();
}

class _TicketConfigPageState extends State<TicketConfigPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(String title, String subtitle, Iterable<String> haystack) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (title.toLowerCase().contains(q)) return true;
    if (subtitle.toLowerCase().contains(q)) return true;
    return haystack.any((item) => item.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: BlocBuilder<TicketConfigCubit, TicketConfig>(
        builder: (context, config) {
          final cubit = context.read<TicketConfigCubit>();
          final sections = <_ConfigSectionData>[
            for (final kind in TicketConfigListKind.values)
              _ConfigSectionData.list(
                kind: kind,
                values: switch (kind) {
                  TicketConfigListKind.applications => config.applications,
                  TicketConfigListKind.distributionLists =>
                    config.distributionLists,
                  TicketConfigListKind.assignees => config.assignees,
                  TicketConfigListKind.bugOptions => config.bugOptions,
                },
              ),
            _ConfigSectionData.priorities(config),
            _ConfigSectionData.sla(config),
          ];
          final visible = sections
              .where(
                (s) => _matches(s.title, s.subtitle, s.previewItems),
              )
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: 'Config',
                subtitle:
                    'Manage dropdown options for Add Ticket and SLA '
                    'targets by priority.',
                trailing: AppButton(
                  label: 'Reset defaults',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => _confirmReset(context, cubit),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _searchController,
                hint: 'Search config sections…',
                prefixIcon: const Icon(Icons.search),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (visible.isEmpty)
                const SizedBox(
                  height: 280,
                  child: AppEmptyState(
                    title: 'No matching sections',
                    message: 'Try a different search term.',
                    icon: Icons.search_off_outlined,
                  ),
                )
              else
                _SectionGrid(
                  children: [
                    for (final section in visible) section.buildCard(context),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    TicketConfigCubit cubit,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset defaults?'),
        content: const Text(
          'This restores all dropdown lists and SLA targets to the '
          'built-in defaults. Your custom options will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true) cubit.resetDefaults();
  }
}

class _ConfigSectionData {
  const _ConfigSectionData._({
    required this.title,
    required this.subtitle,
    required this.previewItems,
    required this.kind,
    required this.buildCard,
  });

  final String title;
  final String subtitle;
  final List<String> previewItems;
  final TicketConfigListKind? kind;
  final Widget Function(BuildContext context) buildCard;

  factory _ConfigSectionData.list({
    required TicketConfigListKind kind,
    required List<String> values,
  }) {
    return _ConfigSectionData._(
      title: kind.title,
      subtitle: kind.subtitle,
      previewItems: values,
      kind: kind,
      buildCard: (context) => _OptionListSectionCard(
        kind: kind,
        values: values,
      ),
    );
  }

  factory _ConfigSectionData.priorities(TicketConfig config) {
    final labels = [
      for (final p in TicketPriority.values)
        '${p.label}${config.enabledPriorities.contains(p) ? '' : ' (off)'}',
    ];
    return _ConfigSectionData._(
      title: 'Priorities',
      subtitle: 'Which priorities appear in the Priority dropdown on Add Ticket.',
      previewItems: labels,
      kind: null,
      buildCard: (context) => _PrioritySection(config: config),
    );
  }

  factory _ConfigSectionData.sla(TicketConfig config) {
    final labels = [
      for (final p in TicketPriority.values)
        '${p.label} ${config.slaFor(p).firstResponse.inHours}h / '
            '${config.slaFor(p).resolution.inHours}h',
    ];
    return _ConfigSectionData._(
      title: 'SLA targets',
      subtitle:
          'First response and resolution clocks by priority. At risk when '
          '≤20% of the target remains.',
      previewItems: labels,
      kind: null,
      buildCard: (context) => _SlaSection(config: config),
    );
  }
}

class _SectionGrid extends StatelessWidget {
  const _SectionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= AppSpacing.sectionGridMinWidth;
        if (!twoCol) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                children[i],
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final left = children[i];
          final right = i + 1 < children.length ? children[i + 1] : null;
          rows.add(
            Padding(
              padding: EdgeInsets.only(
                bottom: i + 2 < children.length ? AppSpacing.md : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: right ?? const SizedBox.shrink()),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

class _OptionListSectionCard extends StatelessWidget {
  const _OptionListSectionCard({
    required this.kind,
    required this.values,
  });

  final TicketConfigListKind kind;
  final List<String> values;

  static const _previewLimit = 8;

  @override
  Widget build(BuildContext context) {
    final preview = values.take(_previewLimit).toList();
    final remaining = values.length - preview.length;

    return _ConfigCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(kind.title, variant: AppTextVariant.sectionTitle),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      kind.subtitle,
                      variant: AppTextVariant.sectionSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                key: ValueKey('config-edit-${kind.pathSegment}'),
                label: 'Edit',
                variant: AppButtonVariant.outlined,
                onPressed: () =>
                    context.go('/ticketing/config/${kind.pathSegment}'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            '${values.length} option${values.length == 1 ? '' : 's'}',
            variant: AppTextVariant.meta,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (values.isEmpty)
            const AppText(
              'No options yet. Open Edit to add some.',
              variant: AppTextVariant.meta,
            )
          else
            _OptionList(
              items: [
                for (final value in preview) value,
                if (remaining > 0) '+$remaining more',
              ],
              mutedLast: remaining > 0,
            ),
        ],
      ),
    );
  }
}

class _OptionList extends StatelessWidget {
  const _OptionList({
    required this.items,
    this.mutedLast = false,
  });

  final List<String> items;
  final bool mutedLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.border),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  items[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: mutedLast && i == items.length - 1
                        ? AppColors.inkTertiary
                        : AppColors.ink,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrioritySection extends StatefulWidget {
  const _PrioritySection({required this.config});

  final TicketConfig config;

  @override
  State<_PrioritySection> createState() => _PrioritySectionState();
}

class _PrioritySectionState extends State<_PrioritySection> {
  bool _editing = false;
  late List<TicketPriority> _draft;
  late List<TicketPriority> _baseline;

  @override
  void initState() {
    super.initState();
    _baseline = List<TicketPriority>.from(widget.config.enabledPriorities);
    _draft = List<TicketPriority>.from(_baseline);
  }

  @override
  void didUpdateWidget(covariant _PrioritySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing &&
        !_samePriorities(
          widget.config.enabledPriorities,
          oldWidget.config.enabledPriorities,
        )) {
      _baseline = List<TicketPriority>.from(widget.config.enabledPriorities);
      _draft = List<TicketPriority>.from(_baseline);
    }
  }

  bool get _isDirty => !_samePriorities(_draft, _baseline);

  static bool _samePriorities(List<TicketPriority> a, List<TicketPriority> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _enterEdit() {
    setState(() {
      _baseline = List<TicketPriority>.from(widget.config.enabledPriorities);
      _draft = List<TicketPriority>.from(_baseline);
      _editing = true;
    });
  }

  Future<void> _cancel() async {
    if (_isDirty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved priority changes. If you cancel now, '
            'those edits will be lost.',
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
      if (ok != true || !mounted) return;
    }
    setState(() {
      _draft = List<TicketPriority>.from(_baseline);
      _editing = false;
    });
  }

  Future<void> _save() async {
    if (!_isDirty) {
      setState(() => _editing = false);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save priorities?'),
        content: const Text(
          'Apply the selected priorities to the Priority dropdown on '
          'Add Ticket.',
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

    context.read<TicketConfigCubit>().setEnabledPriorities(_draft);
    setState(() {
      _baseline = List<TicketPriority>.from(_draft);
      _editing = false;
    });
  }

  void _toggleDraft(TicketPriority priority, bool enabled) {
    if (!_editing) return;
    final current = [..._draft];
    if (enabled) {
      if (!current.contains(priority)) {
        final next = [
          for (final p in TicketPriority.values)
            if (p == priority || current.contains(p)) p,
        ];
        setState(() => _draft = next);
      }
    } else {
      if (current.length <= 1) return;
      setState(
        () => _draft = current.where((p) => p != priority).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = _editing
        ? _draft.toSet()
        : widget.config.enabledPriorities.toSet();

    return _ConfigCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Priorities',
                      variant: AppTextVariant.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    const AppText(
                      'Which priorities appear in the Priority dropdown on '
                      'Add Ticket.',
                      variant: AppTextVariant.sectionSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (_editing) ...[
                AppButton(
                  key: const ValueKey('config-priorities-cancel'),
                  label: 'Cancel',
                  variant: AppButtonVariant.outlined,
                  onPressed: _cancel,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  key: const ValueKey('config-priorities-save'),
                  label: 'Save',
                  onPressed: _save,
                ),
              ] else
                AppButton(
                  key: const ValueKey('config-edit-priorities'),
                  label: 'Edit',
                  variant: AppButtonVariant.outlined,
                  onPressed: _enterEdit,
                ),
            ],
          ),
          if (_editing && _isDirty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Unsaved changes',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < TicketPriority.values.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                  _PriorityListRow(
                    label: TicketPriority.values[i].label,
                    enabled: enabled.contains(TicketPriority.values[i]),
                    editable: _editing,
                    onChanged: (value) =>
                        _toggleDraft(TicketPriority.values[i], value),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityListRow extends StatelessWidget {
  const _PriorityListRow({
    required this.label,
    required this.enabled,
    required this.editable,
    required this.onChanged,
  });

  final String label;
  final bool enabled;
  final bool editable;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: editable ? () => onChanged(!enabled) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Checkbox(
              value: enabled,
              activeColor: AppColors.accent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: editable
                  ? (value) {
                      if (value == null) return;
                      onChanged(value);
                    }
                  : null,
            ),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlaSection extends StatefulWidget {
  const _SlaSection({required this.config});

  final TicketConfig config;

  @override
  State<_SlaSection> createState() => _SlaSectionState();
}

class _SlaSectionState extends State<_SlaSection> {
  bool _editing = false;
  late Map<TicketPriority, SlaTarget> _draft;
  late Map<TicketPriority, SlaTarget> _baseline;

  @override
  void initState() {
    super.initState();
    _baseline = _copySla(widget.config.slaByPriority);
    _draft = _copySla(_baseline);
  }

  @override
  void didUpdateWidget(covariant _SlaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing &&
        !_sameSla(widget.config.slaByPriority, oldWidget.config.slaByPriority)) {
      _baseline = _copySla(widget.config.slaByPriority);
      _draft = _copySla(_baseline);
    }
  }

  bool get _isDirty => !_sameSla(_draft, _baseline);

  static Map<TicketPriority, SlaTarget> _copySla(
    Map<TicketPriority, SlaTarget> source,
  ) {
    return {
      for (final entry in source.entries) entry.key: entry.value,
    };
  }

  static bool _sameSla(
    Map<TicketPriority, SlaTarget> a,
    Map<TicketPriority, SlaTarget> b,
  ) {
    if (a.length != b.length) return false;
    for (final priority in TicketPriority.values) {
      final left = a[priority];
      final right = b[priority];
      if (left == null || right == null) return false;
      if (left.firstResponse != right.firstResponse ||
          left.resolution != right.resolution) {
        return false;
      }
    }
    return true;
  }

  void _enterEdit() {
    setState(() {
      _baseline = _copySla(widget.config.slaByPriority);
      _draft = _copySla(_baseline);
      _editing = true;
    });
  }

  Future<void> _cancel() async {
    if (_isDirty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved SLA changes. If you cancel now, '
            'those edits will be lost.',
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
      if (ok != true || !mounted) return;
    }
    setState(() {
      _draft = _copySla(_baseline);
      _editing = false;
    });
  }

  Future<void> _save() async {
    if (!_isDirty) {
      setState(() => _editing = false);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save SLA targets?'),
        content: const Text(
          'Apply the first-response and resolution targets for each priority.',
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

    final cubit = context.read<TicketConfigCubit>();
    for (final priority in TicketPriority.values) {
      final target = _draft[priority];
      if (target != null) cubit.setSlaTarget(priority, target);
    }
    setState(() {
      _baseline = _copySla(_draft);
      _editing = false;
    });
  }

  void _updateDraft(TicketPriority priority, SlaTarget target) {
    if (!_editing) return;
    setState(() {
      _draft = {
        ..._draft,
        priority: target,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targets = _editing ? _draft : widget.config.slaByPriority;

    return _ConfigCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'SLA targets',
                      variant: AppTextVariant.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    const AppText(
                      'A Service Level Agreement is the promised time to first '
                      'agent reply and to resolve the case. Status becomes At '
                      'risk when ≤20% of the target remains.',
                      variant: AppTextVariant.sectionSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (_editing) ...[
                AppButton(
                  key: const ValueKey('config-sla-cancel'),
                  label: 'Cancel',
                  variant: AppButtonVariant.outlined,
                  onPressed: _cancel,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  key: const ValueKey('config-sla-save'),
                  label: 'Save',
                  onPressed: _save,
                ),
              ] else
                AppButton(
                  key: const ValueKey('config-edit-sla'),
                  label: 'Edit',
                  variant: AppButtonVariant.outlined,
                  onPressed: _enterEdit,
                ),
            ],
          ),
          if (_editing && _isDirty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Unsaved changes',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          for (final priority in TicketPriority.values) ...[
            if (priority != TicketPriority.values.first)
              const SizedBox(height: AppSpacing.sm),
            _SlaPriorityCard(
              priority: priority,
              target: targets[priority] ?? widget.config.slaFor(priority),
              editable: _editing,
              onChanged: (target) => _updateDraft(priority, target),
            ),
          ],
        ],
      ),
    );
  }
}

class _SlaPriorityCard extends StatelessWidget {
  const _SlaPriorityCard({
    required this.priority,
    required this.target,
    required this.editable,
    required this.onChanged,
  });

  final TicketPriority priority;
  final SlaTarget target;
  final bool editable;
  final ValueChanged<SlaTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              priority.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 520;
                final first = _HoursField(
                  label: 'First response (hours)',
                  hours: target.firstResponse.inMinutes / 60,
                  enabled: editable,
                  onChanged: (hours) => onChanged(
                    target.copyWith(
                      firstResponse: Duration(
                        minutes: (hours * 60).round().clamp(1, 60 * 24 * 30),
                      ),
                    ),
                  ),
                );
                final resolution = _HoursField(
                  label: 'Resolution (hours)',
                  hours: target.resolution.inMinutes / 60,
                  enabled: editable,
                  onChanged: (hours) => onChanged(
                    target.copyWith(
                      resolution: Duration(
                        minutes: (hours * 60).round().clamp(1, 60 * 24 * 30),
                      ),
                    ),
                  ),
                );
                if (stacked) {
                  return Column(
                    children: [
                      first,
                      const SizedBox(height: AppSpacing.sm),
                      resolution,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: first),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: resolution),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HoursField extends StatefulWidget {
  const _HoursField({
    required this.label,
    required this.hours,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final double hours;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  State<_HoursField> createState() => _HoursFieldState();
}

class _HoursFieldState extends State<_HoursField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.hours));
  }

  @override
  void didUpdateWidget(covariant _HoursField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _format(widget.hours);
    if (_controller.text != next &&
        double.tryParse(_controller.text) != widget.hours) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _format(double hours) {
    if (hours == hours.roundToDouble()) return hours.toInt().toString();
    return hours.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          readOnly: !widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: const InputDecoration(
            isDense: true,
            suffixText: 'h',
          ),
          onChanged: widget.enabled
              ? (raw) {
                  final parsed = double.tryParse(raw);
                  if (parsed == null) return;
                  widget.onChanged(parsed);
                }
              : null,
        ),
      ],
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}
