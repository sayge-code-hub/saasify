import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_logo.dart';
import 'package:saasify/features/shell/domain/app_modules.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';

class ModuleSidebar extends StatelessWidget {
  const ModuleSidebar({
    this.compact = false,
    this.onNavigate,
    super.key,
  });

  /// When true, used inside a drawer — tapping a leaf closes the drawer.
  final bool compact;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellCubit, ShellState>(
      builder: (context, state) {
        return Material(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // Tab-bar / app icon mark
                    const AppLogoMark(size: 32),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Workspace',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  children: [
                    for (final module in AppModules.all)
                      _ModuleSection(
                        module: module,
                        location: state.location,
                        expanded: state.expandedModuleIds.contains(module.id),
                        onNavigate: onNavigate,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.module,
    required this.location,
    required this.expanded,
    this.onNavigate,
  });

  final NavModule module;
  final String location;
  final bool expanded;
  final VoidCallback? onNavigate;

  void _go(BuildContext context, String location) {
    context.go(location);
    onNavigate?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!module.hasChildren) {
      final active =
          AppModules.isLocationActive(location, module.location ?? '');
      return _NavTile(
        key: ValueKey('nav-${module.id}'),
        label: module.label,
        icon: active ? module.selectedIcon : module.icon,
        active: active,
        onTap: () => _go(context, module.location!),
      );
    }

    final moduleActive = AppModules.isModuleExpandedForPath(module, location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NavTile(
          key: ValueKey('nav-${module.id}'),
          label: module.label,
          icon: moduleActive ? module.selectedIcon : module.icon,
          active: moduleActive && !expanded,
          trailing: Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
            color: AppColors.inkTertiary,
          ),
          onTap: () => context.read<ShellCubit>().toggleModule(module.id),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Column(
              children: [
                for (final child in module.children)
                  _NavTile(
                    key: ValueKey('nav-${child.id}'),
                    label: child.label,
                    dense: true,
                    active: AppModules.isLocationActive(
                      location,
                      child.location,
                    ),
                    onTap: () => _go(context, child.location),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.onTap,
    this.icon,
    this.trailing,
    this.active = false,
    this.dense = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? trailing;
  final bool active;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        active ? AppColors.accent : AppColors.inkSecondary;
    final background =
        active ? AppColors.accentMuted : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          // Ensure the full row receives pointer events on Flutter web.
          mouseCursor: SystemMouseCursors.click,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: dense ? AppSpacing.xs : AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: foreground),
                    const SizedBox(width: AppSpacing.sm),
                  ] else
                    const SizedBox(width: AppSpacing.lg + AppSpacing.xs),
                  Expanded(
                    child: Text(
                      label,
                      style: (dense
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.titleSmall)
                          ?.copyWith(
                        color: active ? AppColors.accent : AppColors.ink,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
