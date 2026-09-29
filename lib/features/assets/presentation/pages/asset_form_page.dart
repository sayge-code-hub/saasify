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
import 'package:saasify/features/assets/data/mock_assets.dart';
import 'package:saasify/features/assets/domain/asset.dart';
import 'package:saasify/features/assets/presentation/bloc/asset_list_cubit.dart';

/// Shared create / edit form for assets.
class AssetFormPage extends StatefulWidget {
  const AssetFormPage({this.assetId, super.key});

  final String? assetId;

  bool get isEditing => assetId != null;

  @override
  State<AssetFormPage> createState() => _AssetFormPageState();
}

class _AssetFormPageState extends State<AssetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _tag;
  late final TextEditingController _type;
  late final TextEditingController _location;
  AssetStatus _status = AssetStatus.inService;
  String? _parentId;
  var _hydrated = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _tag = TextEditingController();
    _type = TextEditingController();
    _location = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _tag.dispose();
    _type.dispose();
    _location.dispose();
    super.dispose();
  }

  void _hydrate(Asset? asset) {
    if (_hydrated || asset == null) return;
    _hydrated = true;
    _name.text = asset.name;
    _tag.text = asset.assetTag;
    _type.text = asset.type;
    _location.text = asset.location;
    _status = asset.status;
    _parentId = asset.parentId;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AssetListCubit>();
    if (widget.isEditing) {
      final existing = cubit.state.byId(widget.assetId!);
      if (existing == null) return;
      cubit.updateAsset(
        existing.copyWith(
          name: _name.text.trim(),
          assetTag: _tag.text.trim(),
          type: _type.text.trim(),
          location: _location.text.trim(),
          status: _status,
          parentId: _parentId,
          clearParent: _parentId == null,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_name.text.trim()} updated.')),
      );
      context.go('/assets/${widget.assetId}');
    } else {
      final id = cubit.createAsset(
        name: _name.text,
        assetTag: _tag.text,
        type: _type.text,
        location: _location.text,
        status: _status,
        parentId: _parentId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_name.text.trim()} created.')),
      );
      context.go('/assets/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;

    return BlocBuilder<AssetListCubit, AssetListState>(
      builder: (context, state) {
        final editing = widget.isEditing
            ? state.byId(widget.assetId!)
            : null;
        if (widget.isEditing && editing == null) {
          return AppPage(
            child: AppEmptyState(
              title: 'Asset not found',
              message: 'This asset may have been removed.',
              actionLabel: 'Back to Asset List',
              onAction: () => context.go('/assets'),
            ),
          );
        }
        _hydrate(editing);

        final parentOptions = state.assets
            .where((a) => a.id != widget.assetId)
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

        return AppPage(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: widget.isEditing ? 'Edit Asset' : 'Add Asset',
                  subtitle: widget.isEditing
                      ? 'Update fields for ${editing!.id}.'
                      : 'Create a new asset in the mock catalog.',
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
                        _twoCol(
                          compact: compact,
                          left: AppTextField(
                            key: const ValueKey('asset-name'),
                            controller: _name,
                            label: 'Name',
                            hint: 'e.g. Charge Pump A',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                          ),
                          right: AppTextField(
                            key: const ValueKey('asset-tag'),
                            controller: _tag,
                            label: 'Asset tag',
                            hint: 'e.g. pump_chg_a',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Asset tag is required'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _twoCol(
                          compact: compact,
                          left: AppTextField(
                            key: const ValueKey('asset-type'),
                            controller: _type,
                            label: 'Type',
                            hint: MockAssets.types.first,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Type is required'
                                    : null,
                          ),
                          right: AppTextField(
                            key: const ValueKey('asset-location'),
                            controller: _location,
                            label: 'Location',
                            hint: MockAssets.locations.first,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Location is required'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const AppText('Status', variant: AppTextVariant.label),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<AssetStatus>(
                          key: ValueKey('asset-status-$_status'),
                          initialValue: _status,
                          items: [
                            for (final status in AssetStatus.values)
                              DropdownMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _status = value);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const AppText('Parent', variant: AppTextVariant.label),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<String?>(
                          key: ValueKey('asset-parent-$_parentId'),
                          initialValue: _parentId,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('None'),
                            ),
                            for (final parent in parentOptions)
                              DropdownMenuItem<String?>(
                                value: parent.id,
                                child: Text(
                                  '${parent.name} [${parent.assetTag}]',
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _parentId = value),
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
                      onPressed: () => context.go('/assets'),
                    ),
                    AppButton(
                      key: const ValueKey('asset-save'),
                      label: widget.isEditing ? 'Save changes' : 'Create asset',
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
