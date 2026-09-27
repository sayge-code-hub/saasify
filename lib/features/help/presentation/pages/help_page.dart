import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/features/help/domain/help_topics.dart';

/// Help hub with request tiles shared across the workspace.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
              final wide =
                  constraints.maxWidth >= AppSpacing.sectionGridMinWidth;
              const tiles = HelpTopic.values;
              if (!wide) {
                return Column(
                  children: [
                    for (var i = 0; i < tiles.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.md),
                      _HelpTile(topic: tiles[i]),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(child: _HelpTile(topic: tiles[i])),
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

class _HelpTile extends StatefulWidget {
  const _HelpTile({required this.topic});

  final HelpTopic topic;

  @override
  State<_HelpTile> createState() => _HelpTileState();
}

class _HelpTileState extends State<_HelpTile> {
  bool _hovered = false;

  void _open() => context.go('/help/${widget.topic.pathSegment}');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = widget.topic;
    final accent = _hovered ? AppColors.accent : AppColors.inkSecondary;
    final borderColor = _hovered ? AppColors.accent : AppColors.border;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: borderColor, width: _hovered ? 1.5 : 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('help-tile-${topic.pathSegment}'),
            onTap: _open,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            hoverColor: AppColors.accentSoft,
            splashColor: AppColors.accentMuted,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(topic.icon, color: accent, size: 28),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        key: ValueKey('help-arrow-${topic.pathSegment}'),
                        color: accent,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    topic.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    topic.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.inkSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
