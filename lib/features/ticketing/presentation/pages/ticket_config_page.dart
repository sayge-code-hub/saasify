import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
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
    final theme = Theme.of(context);

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Config',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Manage dropdown options for Add Ticket and SLA '
                          'targets by priority.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'Reset defaults',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => _confirmReset(context, cubit),
                  ),
                ],
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
    final theme = Theme.of(context);
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
                    Text(
                      kind.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      kind.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
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
          Text(
            '${values.length} option${values.length == 1 ? '' : 's'}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.inkTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (values.isEmpty)
            Text(
              'No options yet. Open Edit to add some.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkTertiary,
              ),
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

class _PrioritySection extends StatelessWidget {
  const _PrioritySection({required this.config});

  final TicketConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<TicketConfigCubit>();

    return _ConfigCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Priorities',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Which priorities appear in the Priority dropdown on Add Ticket.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
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
                    enabled: config.enabledPriorities
                        .contains(TicketPriority.values[i]),
                    onChanged: (value) => cubit.togglePriority(
                      TicketPriority.values[i],
                      value,
                    ),
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
    required this.onChanged,
  });

  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!enabled),
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
              onChanged: (value) {
                if (value == null) return;
                onChanged(value);
              },
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

class _SlaSection extends StatelessWidget {
  const _SlaSection({required this.config});

  final TicketConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ConfigCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SLA targets',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'A Service Level Agreement is the promised time to first agent '
            'reply and to resolve the case. Status becomes At risk when ≤20% '
            'of the target remains.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final priority in TicketPriority.values) ...[
            if (priority != TicketPriority.values.first)
              const SizedBox(height: AppSpacing.sm),
            _SlaPriorityCard(
              priority: priority,
              target: config.slaFor(priority),
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
  });

  final TicketPriority priority;
  final SlaTarget target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<TicketConfigCubit>();

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
                  onChanged: (hours) =>
                      cubit.setFirstResponseHours(priority, hours),
                );
                final resolution = _HoursField(
                  label: 'Resolution (hours)',
                  hours: target.resolution.inMinutes / 60,
                  onChanged: (hours) =>
                      cubit.setResolutionHours(priority, hours),
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
  });

  final String label;
  final double hours;
  final ValueChanged<double> onChanged;

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
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        isDense: true,
        suffixText: 'h',
      ),
      onChanged: (raw) {
        final parsed = double.tryParse(raw);
        if (parsed == null) return;
        widget.onChanged(parsed);
      },
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
