import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/domain/ticket_config.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';

/// Editable queue options (create-form dropdowns) and SLA targets.
class TicketConfigPage extends StatelessWidget {
  const TicketConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPage(
      child: BlocBuilder<TicketConfigCubit, TicketConfig>(
        builder: (context, config) {
          final cubit = context.read<TicketConfigCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
                          'Dropdown options for Add Ticket and SLA clocks that '
                          'measure first response and resolution by priority.',
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
                    onPressed: cubit.resetDefaults,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _EditableOptionList(
                title: 'Applications',
                subtitle: 'Shown in the Application dropdown on Add Ticket.',
                values: config.applications,
                kind: TicketConfigListKind.applications,
              ),
              const SizedBox(height: AppSpacing.lg),
              _EditableOptionList(
                title: 'Distribution lists',
                subtitle: 'Shown in the Distribution List dropdown.',
                values: config.distributionLists,
                kind: TicketConfigListKind.distributionLists,
              ),
              const SizedBox(height: AppSpacing.lg),
              _EditableOptionList(
                title: 'Assignees',
                subtitle:
                    'Agents available when assigning a ticket on the detail page.',
                values: config.assignees,
                kind: TicketConfigListKind.assignees,
                allowEmpty: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              _EditableOptionList(
                title: 'Bug options',
                subtitle: 'Shown in the Bug dropdown (typically No / Yes).',
                values: config.bugOptions,
                kind: TicketConfigListKind.bugOptions,
              ),
              const SizedBox(height: AppSpacing.lg),
              _PrioritySection(config: config),
              const SizedBox(height: AppSpacing.lg),
              _SlaSection(config: config),
            ],
          );
        },
      ),
    );
  }
}

class _EditableOptionList extends StatefulWidget {
  const _EditableOptionList({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.kind,
    this.allowEmpty = false,
  });

  final String title;
  final String subtitle;
  final List<String> values;
  final TicketConfigListKind kind;
  final bool allowEmpty;

  @override
  State<_EditableOptionList> createState() => _EditableOptionListState();
}

class _EditableOptionListState extends State<_EditableOptionList> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    context.read<TicketConfigCubit>().addListItem(
          widget.kind,
          _controller.text,
        );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<TicketConfigCubit>();

    return _ConfigCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            widget.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final value in widget.values)
                InputChip(
                  label: Text(value),
                  onDeleted: (!widget.allowEmpty && widget.values.length <= 1)
                      ? null
                      : () => cubit.removeListItem(widget.kind, value),
                  deleteIconColor: AppColors.inkTertiary,
                  side: const BorderSide(color: AppColors.border),
                  backgroundColor: AppColors.surfaceMuted,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Add option…',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Add',
                variant: AppButtonVariant.outlined,
                onPressed: _add,
              ),
            ],
          ),
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
          for (final priority in TicketPriority.values)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: config.enabledPriorities.contains(priority),
              onChanged: (value) {
                if (value == null) return;
                cubit.togglePriority(priority, value);
              },
              title: Text(priority.label),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.accent,
            ),
        ],
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
            'A Service Level Agreement (SLA) is the promised time to act on a '
            'ticket. First response starts at creation and ends at the first '
            'agent comment. Resolution ends when the ticket is resolved or '
            'closed. Status becomes At risk when ≤20% of the target remains.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final priority in TicketPriority.values) ...[
            if (priority != TicketPriority.values.first)
              const SizedBox(height: AppSpacing.md),
            _SlaPriorityRow(
              priority: priority,
              target: config.slaFor(priority),
            ),
          ],
        ],
      ),
    );
  }
}

class _SlaPriorityRow extends StatelessWidget {
  const _SlaPriorityRow({
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
