import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text_field.dart';

/// Help hub with request tiles shared across the workspace.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const tiles = <_HelpTileData>[
    _HelpTileData(
      keyName: 'help-tile-bug',
      title: 'Raise a bug',
      description:
          'Report something broken in the product so engineering can investigate.',
      icon: Icons.bug_report_outlined,
      formTitle: 'Raise a bug',
      formHint: 'Describe the issue, steps to reproduce, and expected result…',
      submitLabel: 'Submit bug',
    ),
    _HelpTileData(
      keyName: 'help-tile-contact',
      title: 'Contact us',
      description:
          'Reach the Saasify team for account questions, billing, or general support.',
      icon: Icons.mail_outline,
      formTitle: 'Contact us',
      formHint: 'How can we help you today?',
      submitLabel: 'Send message',
    ),
    _HelpTileData(
      keyName: 'help-tile-feature',
      title: 'New feature request',
      description:
          'Suggest an improvement or capability that would help your team work faster.',
      icon: Icons.lightbulb_outline,
      formTitle: 'New feature request',
      formHint: 'Tell us the problem and the feature you would like to see…',
      submitLabel: 'Submit request',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Help',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Get support, report issues, or request new capabilities.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= AppSpacing.sectionGridMinWidth;
              if (!wide) {
                return Column(
                  children: [
                    for (var i = 0; i < tiles.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.md),
                      _HelpTile(data: tiles[i]),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(child: _HelpTile(data: tiles[i])),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HelpTileData {
  const _HelpTileData({
    required this.keyName,
    required this.title,
    required this.description,
    required this.icon,
    required this.formTitle,
    required this.formHint,
    required this.submitLabel,
  });

  final String keyName;
  final String title;
  final String description;
  final IconData icon;
  final String formTitle;
  final String formHint;
  final String submitLabel;
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.data});

  final _HelpTileData data;

  Future<void> _openForm(BuildContext context) async {
    final controller = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data.formTitle),
          content: SizedBox(
            width: 420,
            child: AppTextField(
              controller: controller,
              hint: data.formHint,
              maxLines: 5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.of(context).pop(true);
              },
              child: Text(data.submitLabel),
            ),
          ],
        );
      },
    );
    final text = controller.text.trim();
    controller.dispose();
    if (submitted == true && context.mounted && text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data.title} submitted (mock).'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Icon(data.icon, color: AppColors.inkSecondary, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              data.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              data.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                key: ValueKey(data.keyName),
                label: 'Open',
                variant: AppButtonVariant.outlined,
                onPressed: () => _openForm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
