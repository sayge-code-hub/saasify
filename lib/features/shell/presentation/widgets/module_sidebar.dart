import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_logo.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/settings/presentation/widgets/company_brand_logo.dart';
import 'package:saasify/features/shell/domain/app_modules.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// Maglo-inspired left rail: company brand, nav, Saasify + Sayge footer.
class ModuleSidebar extends StatelessWidget {
  const ModuleSidebar({
    this.compact = false,
    this.onNavigate,
    super.key,
  });

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
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CompanyBrandLogo(height: 28),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  children: [
                    for (final module in AppModules.all)
                      _ModuleSection(
                        module: module,
                        location: state.location,
                        expanded:
                            state.expandedModuleIds.contains(module.id),
                        onNavigate: onNavigate,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    _NavTile(
                      label: 'Help',
                      icon: Icons.help_outline,
                      active: state.location == '/help',
                      onTap: () {
                        context.go('/help');
                        onNavigate?.call();
                      },
                    ),
                    _NavTile(
                      label: 'Logout',
                      icon: Icons.logout,
                      onTap: () {
                        context.read<AuthCubit>().logout();
                        onNavigate?.call();
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: AppSpacing.xs),
                    const _SidebarBrandFooter(),
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

/// Tiny left-aligned Saasify mark + version, with Powered by Sayge under it.
class _SidebarBrandFooter extends StatelessWidget {
  const _SidebarBrandFooter();

  Future<void> _openSayge() async {
    final uri = Uri.parse(AppConstants.saygeUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final micro = theme.textTheme.labelSmall?.copyWith(
      color: AppColors.inkTertiary,
      fontSize: 9,
      height: 1.15,
      fontWeight: FontWeight.w400,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        0,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const AppLogoWordmark(
                key: ValueKey('sidebar-saasify-logo'),
                height: 12,
              ),
              const SizedBox(width: 6),
              GestureDetector(
                key: const ValueKey('app-version-link'),
                onTap: () => context.go('/releases'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    AppConstants.appVersionLabel,
                    style: micro?.copyWith(
                      color: AppColors.inkSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.inkTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              style: micro,
              children: [
                const TextSpan(text: AppConstants.poweredByPrefix),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    key: const ValueKey('powered-by-sayge'),
                    onTap: _openSayge,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        AppConstants.saygeLabel,
                        style: micro?.copyWith(
                          color: AppColors.accent,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
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
    final parentLocation = module.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NavTile(
          key: ValueKey('nav-${module.id}'),
          label: module.label,
          icon: moduleActive ? module.selectedIcon : module.icon,
          active: false,
          trailing: IconButton(
            tooltip: expanded ? 'Collapse' : 'Expand',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: AppColors.inkTertiary,
            ),
            onPressed: () =>
                context.read<ShellCubit>().toggleModule(module.id),
          ),
          onTap: () {
            context.read<ShellCubit>().ensureExpanded(module.id);
            if (parentLocation != null) {
              _go(context, parentLocation);
            }
          },
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
    final foreground = active ? AppColors.accent : AppColors.inkSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: AppColors.surfaceMuted,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: active
                  ? const Border(
                      bottom: BorderSide(
                        color: AppColors.accent,
                        width: 2.5,
                      ),
                    )
                  : null,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
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
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: foreground,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
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
      ),
    );
  }
}
