import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/features/settings/presentation/bloc/company_logo_cubit.dart';
import 'package:saasify/features/settings/presentation/widgets/company_brand_logo.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Workspace branding and preferences.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _CompanyLogoSection(),
        ],
      ),
    );
  }
}

class _CompanyLogoSection extends StatelessWidget {
  const _CompanyLogoSection();

  Future<void> _pickLogo(BuildContext context) async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    late final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not read that image. Try another file.'),
        ),
      );
      return;
    }
    if (bytes.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not read that image. Try another file.'),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    context.read<CompanyLogoCubit>().setBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLogo = context.watch<CompanyLogoCubit>().state != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Company logo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Shown in the top-left of the sidebar. PNG or JPG works best.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.border),
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: CompanyBrandLogo(height: 36),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton(
                  key: const ValueKey('settings-logo-upload'),
                  label: hasLogo ? 'Change logo' : 'Upload logo',
                  onPressed: () => _pickLogo(context),
                ),
                if (hasLogo)
                  AppButton(
                    key: const ValueKey('settings-logo-remove'),
                    label: 'Remove',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.read<CompanyLogoCubit>().clear(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
