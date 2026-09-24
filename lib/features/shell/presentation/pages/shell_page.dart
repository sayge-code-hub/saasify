import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_logo.dart';
import 'package:saasify/core/widgets/app_scaffold.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';
import 'package:saasify/features/shell/presentation/widgets/module_sidebar.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({required this.child, super.key});

  final Widget child;

  static const double sidebarWidth = 260;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final user = switch (context.watch<AuthCubit>().state) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    return AppScaffold(
      appBar: AppBar(
        titleSpacing: compact ? 0 : AppSpacing.md,
        title: Row(
          children: [
            if (!compact) ...[
              const AppLogoMark(size: 28),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        leading: compact
            ? Builder(
                builder: (context) => IconButton(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: PopupMenuButton<_ShellMenuAction>(
                tooltip: 'Account',
                onSelected: (action) {
                  if (action == _ShellMenuAction.signOut) {
                    context.read<AuthCubit>().logout();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ShellMenuAction.signOut,
                    child: Text('Sign out'),
                  ),
                ],
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.accentMuted,
                      foregroundColor: AppColors.accent,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : 'A',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.accent,
                            ),
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(user.name),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ],
                ),
              ),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: compact
          ? Drawer(
              child: ModuleSidebar(
                compact: true,
                onNavigate: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!compact) ...[
            const SizedBox(
              width: sidebarWidth,
              child: ModuleSidebar(),
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

enum _ShellMenuAction { signOut }

/// Syncs [ShellCubit] with the active router location.
class ShellLocationSync extends StatefulWidget {
  const ShellLocationSync({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  @override
  State<ShellLocationSync> createState() => _ShellLocationSyncState();
}

class _ShellLocationSyncState extends State<ShellLocationSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ShellCubit>().setLocation(widget.location);
    });
  }

  @override
  void didUpdateWidget(covariant ShellLocationSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      context.read<ShellCubit>().setLocation(widget.location);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
