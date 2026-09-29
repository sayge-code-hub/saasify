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
import 'package:saasify/features/assets/presentation/bloc/asset_list_cubit.dart';
import 'package:saasify/features/assets/presentation/widgets/asset_status_chip.dart';

/// Simple parent → child tree for MVP 1 (hierarchy from parent links).
class AssetTreePage extends StatelessWidget {
  const AssetTreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetListCubit, AssetListState>(
      builder: (context, state) {
        final roots = state.roots;

        return AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: 'Asset Tree',
                subtitle:
                    'Hierarchy from parent links in the mock catalog. '
                    'Reports and advanced tree tools come in later MVP steps.',
                trailing: AppButton(
                  label: 'Asset List',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => context.go('/assets'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (roots.isEmpty)
                const SizedBox(
                  height: 280,
                  child: AppEmptyState(
                    title: 'No assets yet',
                    message: 'Add an asset to see it in the tree.',
                    icon: Icons.account_tree_outlined,
                  ),
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      children: [
                        for (final root in roots)
                          _AssetTreeNode(
                            asset: root,
                            depth: 0,
                            state: state,
                          ),
                      ],
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

class _AssetTreeNode extends StatelessWidget {
  const _AssetTreeNode({
    required this.asset,
    required this.depth,
    required this.state,
  });

  final Asset asset;
  final int depth;
  final AssetListState state;

  @override
  Widget build(BuildContext context) {
    final children = state.childrenOf(asset.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => context.go('/assets/${asset.id}'),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md + depth * AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  children.isEmpty
                      ? Icons.circle
                      : Icons.account_tree_outlined,
                  size: children.isEmpty ? 8 : 18,
                  color: AppColors.inkSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        asset.name,
                        variant: AppTextVariant.sectionTitle,
                      ),
                      AppText(
                        '${asset.assetTag} · ${asset.location}',
                        variant: AppTextVariant.meta,
                      ),
                    ],
                  ),
                ),
                AssetStatusChip(status: asset.status),
              ],
            ),
          ),
        ),
        for (final child in children)
          _AssetTreeNode(asset: child, depth: depth + 1, state: state),
      ],
    );
  }
}
