import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/features/assets/domain/asset.dart';
import 'package:saasify/features/assets/domain/pm_plan.dart';
import 'package:saasify/features/assets/presentation/bloc/asset_list_cubit.dart';
import 'package:saasify/features/assets/presentation/bloc/pm_plan_cubit.dart';
import 'package:saasify/features/assets/presentation/pages/asset_form_page.dart';
import 'package:saasify/features/assets/presentation/widgets/asset_status_chip.dart';
import 'package:saasify/features/assets/presentation/widgets/pm_status_chip.dart';

class AssetDetailPage extends StatelessWidget {
  const AssetDetailPage({required this.assetId, super.key});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    // Reuse the form for edit when navigated with ?edit — default shows summary
    // then Edit opens the form route pattern via /assets/:id/edit.
    // For MVP1 we show a read view with Edit that goes to the form page.
    return BlocBuilder<AssetListCubit, AssetListState>(
      builder: (context, state) {
        final asset = state.byId(assetId);
        if (asset == null) {
          return AppPage(
            child: AppEmptyState(
              title: 'Asset not found',
              message: 'This asset may have been removed from the mock set.',
              actionLabel: 'Back to Asset List',
              onAction: () => context.go('/assets'),
            ),
          );
        }

        final children = state.childrenOf(asset.id);
        final pmPlans = context.watch<PmPlanCubit>().state.forAsset(asset.id);
        final now = DateTime.now();

        return AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('asset-detail-back'),
                  onPressed: () => context.go('/assets'),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Asset List'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(asset.id, variant: AppTextVariant.meta),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      asset.name,
                      variant: AppTextVariant.pageTitle,
                    ),
                  ),
                  AssetStatusChip(status: asset.status),
                ],
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
                        'Details',
                        variant: AppTextVariant.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _DetailRow(label: 'Asset tag', value: asset.assetTag),
                      _DetailRow(label: 'Type', value: asset.type),
                      _DetailRow(label: 'Location', value: asset.location),
                      _DetailRow(label: 'Parent', value: asset.parentLabel),
                      _DetailRow(label: 'Status', value: asset.status.label),
                    ],
                  ),
                ),
              ),
              if (children.isNotEmpty) ...[
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
                        AppText(
                          'Child assets (${children.length})',
                          variant: AppTextVariant.sectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final child in children)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(child.name),
                            subtitle: Text(child.assetTag),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.go('/assets/${child.id}'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
                      Row(
                        children: [
                          const Expanded(
                            child: AppText(
                              'Preventive maintenance',
                              variant: AppTextVariant.sectionTitle,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(
                              '/assets/pm?asset=$assetId',
                            ),
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (pmPlans.isEmpty)
                        const AppText(
                          'No PM plans for this asset yet.',
                          variant: AppTextVariant.meta,
                        )
                      else
                        for (final plan in pmPlans.take(3))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(plan.maintenanceType),
                            subtitle: Text(
                              '${plan.frequency.label} · Next '
                              '${formatPmDate(plan.nextDueDate)}',
                            ),
                            trailing: PmStatusChip(status: plan.statusAt(now)),
                            onTap: () => context.go('/assets/pm/${plan.id}'),
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
                    key: const ValueKey('asset-detail-edit'),
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: () => context.go('/assets/$assetId/edit'),
                  ),
                  AppButton(
                    label: 'PM Schedule',
                    variant: AppButtonVariant.outlined,
                    icon: Icons.event_available_outlined,
                    onPressed: () => context.go('/assets/pm?asset=$assetId'),
                  ),
                  AppButton(
                    label: 'Asset Tree',
                    variant: AppButtonVariant.outlined,
                    icon: Icons.account_tree_outlined,
                    onPressed: () => context.go('/assets/tree'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: AppText(label, variant: AppTextVariant.meta),
          ),
          Expanded(
            child: AppText(value, variant: AppTextVariant.body),
          ),
        ],
      ),
    );
  }
}

/// Edit route wrapper so `/assets/:id/edit` uses the shared form.
class AssetEditPage extends StatelessWidget {
  const AssetEditPage({required this.assetId, super.key});

  final String assetId;

  @override
  Widget build(BuildContext context) => AssetFormPage(assetId: assetId);
}
