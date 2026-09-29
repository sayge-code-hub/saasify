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
import 'package:saasify/features/assets/domain/asset.dart';
import 'package:saasify/features/assets/presentation/bloc/asset_list_cubit.dart';
import 'package:saasify/features/assets/presentation/widgets/asset_status_chip.dart';

class AssetListPage extends StatefulWidget {
  const AssetListPage({super.key});

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<AssetListCubit>().state.query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Asset asset) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete asset'),
        content: Text('Remove “${asset.name}” from the mock catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<AssetListCubit>().deleteAsset(asset.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${asset.name} deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final horizontal = compact
        ? AppSpacing.pagePaddingCompact
        : AppSpacing.pagePaddingExpanded;

    return BlocBuilder<AssetListCubit, AssetListState>(
      builder: (context, state) {
        final assets = state.visible;

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
                          'Asset List',
                          variant: AppTextVariant.pageTitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _Toolbar(
                          compact: compact,
                          searchController: _searchController,
                          onSearchChanged:
                              context.read<AssetListCubit>().setQuery,
                          onAdd: () => context.go('/assets/new'),
                          onTree: () => context.go('/assets/tree'),
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
                        child: assets.isEmpty
                            ? const AppEmptyState(
                                title: 'No assets match',
                                message: 'Try another search or add an asset.',
                                icon: Icons.precision_manufacturing_outlined,
                              )
                            : Column(
                                children: [
                                  if (!compact) const _TableHeader(),
                                  if (!compact) const Divider(height: 1),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: assets.length,
                                      separatorBuilder: (_, _) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final asset = assets[index];
                                        final zebra = index.isOdd;
                                        if (compact) {
                                          return _AssetCard(
                                            asset: asset,
                                            onOpen: () => context.go(
                                              '/assets/${asset.id}',
                                            ),
                                            onEdit: () => context.go(
                                              '/assets/${asset.id}',
                                            ),
                                            onDelete: () =>
                                                _confirmDelete(asset),
                                          );
                                        }
                                        return _AssetRow(
                                          asset: asset,
                                          zebra: zebra,
                                          onOpen: () => context.go(
                                            '/assets/${asset.id}',
                                          ),
                                          onEdit: () => context.go(
                                            '/assets/${asset.id}',
                                          ),
                                          onDelete: () =>
                                              _confirmDelete(asset),
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
    required this.onAdd,
    required this.onTree,
  });

  final bool compact;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAdd;
  final VoidCallback onTree;

  @override
  Widget build(BuildContext context) {
    final search = AppTextField(
      controller: searchController,
      hint: 'Search by name, tag, type, or location',
      prefixIcon: const Icon(Icons.search, size: 20),
      onChanged: onSearchChanged,
    );

    final actions = Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: [
        AppButton(
          key: const ValueKey('asset-add'),
          label: 'Add Asset',
          icon: Icons.add,
          onPressed: onAdd,
        ),
        AppButton(
          key: const ValueKey('asset-tree-nav'),
          label: 'Asset Tree',
          variant: AppButtonVariant.outlined,
          icon: Icons.account_tree_outlined,
          onPressed: onTree,
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(flex: 3, child: Text('NAME', style: style)),
          Expanded(flex: 2, child: Text('ASSET TAG', style: style)),
          Expanded(flex: 2, child: Text('TYPE', style: style)),
          Expanded(flex: 2, child: Text('LOCATION', style: style)),
          Expanded(flex: 3, child: Text('PARENT', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
          const SizedBox(width: 120, child: Text('')),
        ],
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({
    required this.asset,
    required this.zebra,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Asset asset;
  final bool zebra;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                flex: 3,
                child: Text(
                  asset.name,
                  style: AppText.styleFor(context, AppTextVariant.body)
                      .copyWith(color: AppColors.accent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  asset.assetTag,
                  variant: AppTextVariant.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  asset.type,
                  variant: AppTextVariant.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: AppText(
                  asset.location,
                  variant: AppTextVariant.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 3,
                child: AppText(
                  asset.parentLabel,
                  variant: AppTextVariant.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(flex: 2, child: AssetStatusChip(status: asset.status)),
              SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
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

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.asset,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Asset asset;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                    asset.name,
                    variant: AppTextVariant.sectionTitle,
                    color: AppColors.accent,
                  ),
                ),
                AssetStatusChip(status: asset.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(asset.assetTag, variant: AppTextVariant.meta),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              '${asset.type} · ${asset.location}',
              variant: AppTextVariant.body,
            ),
            if (asset.parentName != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              AppText(
                'Parent: ${asset.parentLabel}',
                variant: AppTextVariant.meta,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
