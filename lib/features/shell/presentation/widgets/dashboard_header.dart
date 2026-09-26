import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

/// Maglo-style top chrome inside the main column (title left, actions right).
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.title,
    this.leading,
    this.userName,
    this.showMenu = false,
    this.onMenu,
    super.key,
  });

  final String title;

  /// Optional leading content (e.g. back + “All tickets”) instead of [title].
  final Widget? leading;
  final String? userName;
  final bool showMenu;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSettings = GoRouterState.of(context).uri.path == '/settings';

    return Material(
      color: AppColors.surface,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              if (showMenu)
                IconButton(
                  tooltip: 'Menu',
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu),
                ),
              Expanded(
                child: leading ??
                    (title.isEmpty
                        ? const SizedBox.shrink()
                        : Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
              ),
              IconButton(
                tooltip: 'Search',
                onPressed: () {},
                icon: const Icon(Icons.search, color: AppColors.ink),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.ink,
                ),
              ),
              IconButton(
                key: const ValueKey('header-settings'),
                tooltip: 'Settings',
                onPressed: () => context.go('/settings'),
                icon: Icon(
                  onSettings ? Icons.settings : Icons.settings_outlined,
                  color: onSettings ? AppColors.accent : AppColors.ink,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PopupMenuButton<_HeaderAction>(
                tooltip: 'Account',
                onSelected: (action) {
                  if (action == _HeaderAction.signOut) {
                    context.read<AuthCubit>().logout();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _HeaderAction.signOut,
                    child: Text('Sign out'),
                  ),
                ],
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.accentMuted,
                      foregroundColor: AppColors.accentHover,
                      child: Text(
                        (userName != null && userName!.isNotEmpty)
                            ? userName![0].toUpperCase()
                            : 'A',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.accentHover,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (userName != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        userName!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.ink,
                      ),
                    ],
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

enum _HeaderAction { signOut }
