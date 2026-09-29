import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/assets/data/mock_pm_plans.dart';
import 'package:saasify/features/assets/domain/pm_plan.dart';
import 'package:saasify/features/assets/presentation/bloc/asset_list_cubit.dart';
import 'package:saasify/features/assets/presentation/bloc/pm_plan_cubit.dart';
import 'package:saasify/features/assets/presentation/widgets/pm_status_chip.dart';

class PmFormPage extends StatefulWidget {
  const PmFormPage({this.planId, super.key});

  final String? planId;

  bool get isEditing => planId != null;

  @override
  State<PmFormPage> createState() => _PmFormPageState();
}

class _PmFormPageState extends State<PmFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _type;
  late final TextEditingController _team;
  late final TextEditingController _technician;
  late final TextEditingController _instructions;
  late final TextEditingController _durationHours;
  late final TextEditingController _checklistText;
  String? _assetId;
  PmFrequency _frequency = PmFrequency.monthly;
  PmPriority _priority = PmPriority.medium;
  DateTime _startDate = DateTime.now();
  DateTime _nextDue = DateTime.now().add(const Duration(days: 30));
  var _hydrated = false;

  @override
  void initState() {
    super.initState();
    _type = TextEditingController();
    _team = TextEditingController(text: MockPmPlans.teams.first);
    _technician = TextEditingController(text: MockPmPlans.technicians.first);
    _instructions = TextEditingController();
    _durationHours = TextEditingController(text: '2');
    _checklistText = TextEditingController(
      text: 'Check vibration\nCheck oil level\nInspect coupling\nCheck leakage',
    );
  }

  @override
  void dispose() {
    _type.dispose();
    _team.dispose();
    _technician.dispose();
    _instructions.dispose();
    _durationHours.dispose();
    _checklistText.dispose();
    super.dispose();
  }

  void _hydrate(PmPlan? plan) {
    if (_hydrated || plan == null) return;
    _hydrated = true;
    _assetId = plan.assetId;
    _type.text = plan.maintenanceType;
    _team.text = plan.assignedTeam;
    _technician.text = plan.assignedTechnician;
    _instructions.text = plan.instructions;
    _frequency = plan.frequency;
    _priority = plan.priority;
    _startDate = plan.startDate;
    _nextDue = plan.nextDueDate;
    _durationHours.text =
        (plan.estimatedDuration.inMinutes / 60).toStringAsFixed(
      plan.estimatedDuration.inMinutes % 60 == 0 ? 0 : 1,
    );
    _checklistText.text = plan.checklist.map((c) => c.label).join('\n');
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _startDate : _nextDue;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startDate = picked;
      } else {
        _nextDue = picked;
      }
    });
  }

  List<PmChecklistItem> _parseChecklist() {
    final lines = _checklistText.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    return [
      for (var i = 0; i < lines.length; i++)
        PmChecklistItem(id: 'c${i + 1}', label: lines[i]),
    ];
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_assetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an asset.')),
      );
      return;
    }
    final assets = context.read<AssetListCubit>().state;
    final asset = assets.byId(_assetId!);
    if (asset == null) return;

    final hours = double.tryParse(_durationHours.text.trim()) ?? 1;
    final duration = Duration(minutes: (hours * 60).round());
    final checklist = _parseChecklist();
    if (checklist.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one checklist item.')),
      );
      return;
    }

    final cubit = context.read<PmPlanCubit>();
    if (widget.isEditing) {
      final existing = cubit.state.byId(widget.planId!);
      if (existing == null) return;
      cubit.updatePlan(
        existing.copyWith(
          assetId: asset.id,
          assetName: asset.name,
          maintenanceType: _type.text.trim(),
          frequency: _frequency,
          startDate: _startDate,
          nextDueDate: _nextDue,
          assignedTeam: _team.text.trim(),
          assignedTechnician: _technician.text.trim(),
          priority: _priority,
          checklist: checklist,
          estimatedDuration: duration,
          instructions: _instructions.text.trim(),
        ),
      );
      context.go('/assets/pm/${existing.id}');
    } else {
      final id = cubit.createPlan(
        PmPlan(
          id: 'PM-temp',
          assetId: asset.id,
          assetName: asset.name,
          maintenanceType: _type.text.trim(),
          frequency: _frequency,
          startDate: _startDate,
          nextDueDate: _nextDue,
          assignedTeam: _team.text.trim(),
          assignedTechnician: _technician.text.trim(),
          priority: _priority,
          checklist: checklist,
          estimatedDuration: duration,
          instructions: _instructions.text.trim(),
          status: PmPlanStatus.scheduled,
        ),
      );
      context.go('/assets/pm/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;

    return BlocBuilder<PmPlanCubit, PmPlanState>(
      builder: (context, pmState) {
        final editing =
            widget.isEditing ? pmState.byId(widget.planId!) : null;
        if (widget.isEditing && editing == null) {
          return AppPage(
            child: AppEmptyState(
              title: 'PM plan not found',
              message: 'This plan may have been removed.',
              actionLabel: 'Back to PM Schedule',
              onAction: () => context.go('/assets/pm'),
            ),
          );
        }
        _hydrate(editing);

        final assets = context.watch<AssetListCubit>().state.assets.toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
        _assetId ??= assets.isEmpty ? null : assets.first.id;

        return AppPage(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: widget.isEditing ? 'Edit PM Plan' : 'Add PM Plan',
                  subtitle:
                      'Link preventive maintenance to an asset with frequency, '
                      'team, and checklist.',
                ),
                const SizedBox(height: AppSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppText('Asset', variant: AppTextVariant.label),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<String>(
                          key: ValueKey('pm-asset-$_assetId'),
                          initialValue: _assetId,
                          items: [
                            for (final asset in assets)
                              DropdownMenuItem(
                                value: asset.id,
                                child: Text('${asset.name} [${asset.assetTag}]'),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _assetId = value),
                          validator: (v) =>
                              v == null ? 'Asset is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _twoCol(
                          compact: compact,
                          left: AppTextField(
                            key: const ValueKey('pm-type'),
                            controller: _type,
                            label: 'Maintenance type',
                            hint: MockPmPlans.maintenanceTypes.first,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          right: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const AppText(
                                'Frequency',
                                variant: AppTextVariant.label,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              DropdownButtonFormField<PmFrequency>(
                                key: ValueKey('pm-freq-$_frequency'),
                                initialValue: _frequency,
                                items: [
                                  for (final f in PmFrequency.values)
                                    DropdownMenuItem(
                                      value: f,
                                      child: Text(f.label),
                                    ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => _frequency = v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _twoCol(
                          compact: compact,
                          left: _DateField(
                            label: 'Start date',
                            value: formatPmDate(_startDate),
                            onTap: () => _pickDate(start: true),
                          ),
                          right: _DateField(
                            label: 'Next due date',
                            value: formatPmDate(_nextDue),
                            onTap: () => _pickDate(start: false),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _twoCol(
                          compact: compact,
                          left: AppTextField(
                            key: const ValueKey('pm-team'),
                            controller: _team,
                            label: 'Assigned team',
                          ),
                          right: AppTextField(
                            key: const ValueKey('pm-tech'),
                            controller: _technician,
                            label: 'Assigned technician',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _twoCol(
                          compact: compact,
                          left: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const AppText(
                                'Priority',
                                variant: AppTextVariant.label,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              DropdownButtonFormField<PmPriority>(
                                key: ValueKey('pm-priority-$_priority'),
                                initialValue: _priority,
                                items: [
                                  for (final p in PmPriority.values)
                                    DropdownMenuItem(
                                      value: p,
                                      child: Text(p.label),
                                    ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => _priority = v);
                                },
                              ),
                            ],
                          ),
                          right: AppTextField(
                            key: const ValueKey('pm-duration'),
                            controller: _durationHours,
                            label: 'Estimated duration (hours)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          key: const ValueKey('pm-checklist'),
                          controller: _checklistText,
                          label: 'Checklist (one item per line)',
                          maxLines: 5,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          key: const ValueKey('pm-instructions'),
                          controller: _instructions,
                          label: 'Instructions',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.end,
                  children: [
                    AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => context.go(
                        widget.isEditing
                            ? '/assets/pm/${widget.planId}'
                            : '/assets/pm',
                      ),
                    ),
                    AppButton(
                      key: const ValueKey('pm-save'),
                      label: widget.isEditing ? 'Save changes' : 'Create PM plan',
                      onPressed: _save,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _twoCol({
    required bool compact,
    required Widget left,
    required Widget right,
  }) {
    if (compact) {
      return Column(
        children: [
          left,
          const SizedBox(height: AppSpacing.md),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: right),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(label, variant: AppTextVariant.label),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          child: Text(value, style: AppText.styleFor(context, AppTextVariant.body)),
        ),
      ],
    );
  }
}
