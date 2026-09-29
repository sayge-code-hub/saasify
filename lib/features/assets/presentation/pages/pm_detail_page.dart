import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/features/assets/domain/pm_plan.dart';
import 'package:saasify/features/assets/presentation/bloc/pm_plan_cubit.dart';
import 'package:saasify/features/assets/presentation/widgets/pm_status_chip.dart';

class PmDetailPage extends StatelessWidget {
  const PmDetailPage({required this.planId, super.key});

  final String planId;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return BlocBuilder<PmPlanCubit, PmPlanState>(
      builder: (context, state) {
        final plan = state.byId(planId);
        if (plan == null) {
          return AppPage(
            child: AppEmptyState(
              title: 'PM plan not found',
              message: 'This plan may have been removed from the mock set.',
              actionLabel: 'Back to PM Schedule',
              onAction: () => context.go('/assets/pm'),
            ),
          );
        }

        final status = plan.statusAt(now);
        final cubit = context.read<PmPlanCubit>();

        return AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('pm-detail-back'),
                  onPressed: () => context.go('/assets/pm'),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('PM Schedule'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(plan.id, variant: AppTextVariant.meta),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppText(
                      '${plan.assetName} · ${plan.maintenanceType}',
                      variant: AppTextVariant.pageTitle,
                    ),
                  ),
                  PmStatusChip(status: status),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                '${plan.frequency.label} · Next due ${formatPmDate(plan.nextDueDate)}',
                variant: AppTextVariant.pageSubtitle,
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
                      const AppText(
                        'Plan details',
                        variant: AppTextVariant.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Row(label: 'Asset', value: plan.assetName, onTap: () {
                        context.go('/assets/${plan.assetId}');
                      }),
                      _Row(label: 'Type', value: plan.maintenanceType),
                      _Row(label: 'Frequency', value: plan.frequency.label),
                      _Row(
                        label: 'Start date',
                        value: formatPmDate(plan.startDate),
                      ),
                      _Row(
                        label: 'Next due',
                        value: formatPmDate(plan.nextDueDate),
                      ),
                      _Row(
                        label: 'Last completed',
                        value: plan.lastCompleted == null
                            ? '—'
                            : formatPmDate(plan.lastCompleted!),
                      ),
                      _Row(label: 'Assigned team', value: plan.assignedTeam),
                      _Row(
                        label: 'Technician',
                        value: plan.assignedTechnician,
                      ),
                      _Row(label: 'Priority', value: plan.priority.label),
                      _Row(
                        label: 'Est. duration',
                        value: formatPmDuration(plan.estimatedDuration),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                      const AppText(
                        'Checklist',
                        variant: AppTextVariant.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final item in plan.checklist)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: ValueKey('pm-check-${item.id}'),
                            onTap: () =>
                                cubit.toggleChecklistItem(plan.id, item.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: item.done,
                                    onChanged: (_) => cubit.toggleChecklistItem(
                                      plan.id,
                                      item.id,
                                    ),
                                  ),
                                  Expanded(
                                    child: AppText(
                                      item.label,
                                      variant: AppTextVariant.body,
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
              const SizedBox(height: AppSpacing.md),
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
                      const AppText(
                        'Instructions',
                        variant: AppTextVariant.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppText(
                        plan.instructions,
                        variant: AppTextVariant.body,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppButton(
                    key: const ValueKey('pm-complete'),
                    label: 'Mark completed',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      cubit.completePlan(plan.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${plan.id} completed. Next due '
                            '${formatPmDate(plan.frequency.nextDueAfter(DateTime.now()))}.',
                          ),
                        ),
                      );
                    },
                  ),
                  AppButton(
                    key: const ValueKey('pm-detail-edit'),
                    label: 'Edit plan',
                    variant: AppButtonVariant.outlined,
                    icon: Icons.edit_outlined,
                    onPressed: () => context.go('/assets/pm/${plan.id}/edit'),
                  ),
                  AppButton(
                    label: 'Open asset',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.go('/assets/${plan.assetId}'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppText(
                'Next step later: PM Due → Work Order → technician completes → history.',
                variant: AppTextVariant.meta,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final valueWidget = onTap == null
        ? AppText(value, variant: AppTextVariant.body)
        : InkWell(
            onTap: onTap,
            child: AppText(
              value,
              variant: AppTextVariant.body,
              color: AppColors.accent,
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: AppText(label, variant: AppTextVariant.meta),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }
}
