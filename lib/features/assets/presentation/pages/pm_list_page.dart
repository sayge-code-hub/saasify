import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/assets/domain/pm_plan.dart';
import 'package:saasify/features/assets/presentation/bloc/pm_plan_cubit.dart';
import 'package:saasify/features/assets/presentation/widgets/pm_status_chip.dart';

class PmListPage extends StatefulWidget {
  const PmListPage({super.key, this.initialAssetId});

  final String? initialAssetId;

  @override
  State<PmListPage> createState() => _PmListPageState();
}

class _PmListPageState extends State<PmListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PmPlanCubit>();
    _searchController = TextEditingController(text: cubit.state.query);
    if (widget.initialAssetId != null) {
      cubit.setAssetFilter(widget.initialAssetId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final horizontal = compact
        ? AppSpacing.pagePaddingCompact
        : AppSpacing.pagePaddingExpanded;
    final now = DateTime.now();

    return BlocBuilder<PmPlanCubit, PmPlanState>(
      builder: (context, state) {
        final plans = state.visible;
        String? filterLabel;
        if (state.assetFilterId != null) {
          for (final plan in state.plans) {
            if (plan.assetId == state.assetFilterId) {
              filterLabel = plan.assetName;
              break;
            }
          }
        }

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
                        const AppText(
                          'PM Schedule',
                          variant: AppTextVariant.pageTitle,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          filterLabel == null
                              ? 'Preventive maintenance plans linked to assets. '
                                  'Due work is sorted first.'
                              : 'Showing PM plans for $filterLabel.',
                          variant: AppTextVariant.pageSubtitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _Toolbar(
                          compact: compact,
                          searchController: _searchController,
                          onSearchChanged:
                              context.read<PmPlanCubit>().setQuery,
                          assetFilterActive: state.assetFilterId != null,
                          onClearFilter: () =>
                              context.read<PmPlanCubit>().setAssetFilter(null),
                          onAdd: () => context.go('/assets/pm/new'),
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
                        child: plans.isEmpty
                            ? const AppEmptyState(
                                title: 'No PM plans match',
                                message:
                                    'Try another search or create a PM plan.',
                                icon: Icons.event_available_outlined,
                              )
                            : Column(
                                children: [
                                  if (!compact) const _TableHeader(),
                                  if (!compact) const Divider(height: 1),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: plans.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final plan = plans[index];
                                        final status = plan.statusAt(now);
                                        void open() =>
                                            context.go('/assets/pm/${plan.id}');
                                        if (compact) {
                                          return _PmCard(
                                            plan: plan,
                                            status: status,
                                            onOpen: open,
                                          );
                                        }
                                        return _PmRow(
                                          plan: plan,
                                          status: status,
                                          zebra: index.isOdd,
                                          onOpen: open,
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

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.compact,
    required this.searchController,
    required this.onSearchChanged,
    required this.assetFilterActive,
    required this.onClearFilter,
    required this.onAdd,
  });

  final bool compact;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool assetFilterActive;
  final VoidCallback onClearFilter;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final search = AppTextField(
      controller: searchController,
      hint: 'Search by PM ID, asset, type, or team',
      prefixIcon: const Icon(Icons.search, size: 20),
      onChanged: onSearchChanged,
    );
    final actions = Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: [
        if (assetFilterActive)
          AppButton(
            label: 'Clear asset filter',
            variant: AppButtonVariant.outlined,
            onPressed: onClearFilter,
          ),
        AppButton(
          key: const ValueKey('pm-add'),
          label: 'Add PM Plan',
          icon: Icons.add,
          onPressed: onAdd,
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: AppSpacing.sm),
          actions,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: search),
        const SizedBox(width: AppSpacing.md),
        actions,
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = AppText.styleFor(context, AppTextVariant.meta).copyWith(
      letterSpacing: 0.6,
      fontSize: 11,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('PM ID', style: style)),
          Expanded(flex: 3, child: Text('ASSET', style: style)),
          Expanded(flex: 2, child: Text('TYPE', style: style)),
          Expanded(flex: 2, child: Text('FREQUENCY', style: style)),
          Expanded(flex: 2, child: Text('NEXT DUE', style: style)),
          Expanded(flex: 2, child: Text('TEAM', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
        ],
      ),
    );
  }
}

class _PmRow extends StatelessWidget {
  const _PmRow({
    required this.plan,
    required this.status,
    required this.zebra,
    required this.onOpen,
  });

  final PmPlan plan;
  final PmPlanStatus status;
  final bool zebra;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: zebra ? AppColors.surfaceMuted : AppColors.surface,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: AppText(plan.id, variant: AppTextVariant.meta),
              ),
              Expanded(
                flex: 3,
                child: AppText(
                  plan.assetName,
                  variant: AppTextVariant.body,
                  color: AppColors.accent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  plan.maintenanceType,
                  variant: AppTextVariant.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  plan.frequency.label,
                  variant: AppTextVariant.body,
                ),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  formatPmDate(plan.nextDueDate),
                  variant: AppTextVariant.body,
                ),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  plan.assignedTeam,
                  variant: AppTextVariant.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(flex: 2, child: PmStatusChip(status: status)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PmCard extends StatelessWidget {
  const _PmCard({
    required this.plan,
    required this.status,
    required this.onOpen,
  });

  final PmPlan plan;
  final PmPlanStatus status;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    plan.assetName,
                    variant: AppTextVariant.sectionTitle,
                    color: AppColors.accent,
                  ),
                ),
                PmStatusChip(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              '${plan.maintenanceType} · ${plan.frequency.label}',
              variant: AppTextVariant.body,
            ),
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              'Next due ${formatPmDate(plan.nextDueDate)} · ${plan.assignedTeam}',
              variant: AppTextVariant.meta,
            ),
            const SizedBox(height: AppSpacing.xxs),
            AppText(plan.id, variant: AppTextVariant.meta),
          ],
        ),
      ),
    );
  }
}
