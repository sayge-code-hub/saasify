import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/widgets/app_scaffold.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';
import 'package:saasify/features/shell/presentation/widgets/dashboard_header.dart';
import 'package:saasify/features/shell/presentation/widgets/module_sidebar.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({required this.child, super.key});

  final Widget child;

  static const double sidebarWidth = 248;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final location = context.watch<ShellCubit>().state.location;
    final user = switch (context.watch<AuthCubit>().state) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };
    final onTicketDetail = location.startsWith('/ticketing/tickets/');

    return AppScaffold(
      backgroundColor: AppColors.canvas,
      drawer: compact
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: ModuleSidebar(
                compact: true,
                onNavigate: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[
            const SizedBox(width: sidebarWidth, child: ModuleSidebar()),
            const VerticalDivider(width: 1),
          ],
          Expanded(
            child: Builder(
              builder: (scaffoldContext) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeader(
                      title: dashboardTitleFor(location),
                      leading: onTicketDetail
                          ? _TicketDetailHeaderBack(
                              onPressed: () => context.go('/ticketing/all'),
                            )
                          : null,
                      userName: user?.name,
                      showMenu: compact,
                      onMenu: compact
                          ? () => Scaffold.of(scaffoldContext).openDrawer()
                          : null,
                    ),
                    Expanded(child: SelectionArea(child: child)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketDetailHeaderBack extends StatelessWidget {
  const _TicketDetailHeaderBack({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        key: const ValueKey('header-back-all-tickets'),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        icon: const Icon(Icons.arrow_back, size: 20),
        label: Text(
          'All tickets',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String dashboardTitleFor(String location) {
  if (location == '/ticketing' || location == '/') return 'Dashboard';
  if (location.startsWith('/ticketing/tickets/')) {
    // Leading back control replaces the title on ticket detail.
    return '';
  }
  if (location == '/ticketing/new') return 'Add Ticket';
  // List views and Config keep the page title in content; header stays clean.
  if (location == '/ticketing/all' ||
      location == '/ticketing/open' ||
      location == '/ticketing/pending' ||
      location == '/ticketing/resolved' ||
      location == '/ticketing/priority' ||
      location == '/ticketing/config' ||
      location.startsWith('/ticketing/config/')) {
    return '';
  }
  if (location == '/dynamic/create-ticket') return 'Add Ticket (BDUI)';
  if (location == '/settings') return 'Settings';
  return 'Workspace';
}

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
