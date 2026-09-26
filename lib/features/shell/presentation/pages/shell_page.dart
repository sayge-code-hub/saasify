import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            const SizedBox(
              width: sidebarWidth,
              child: ModuleSidebar(),
            ),
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
                      userName: user?.name,
                      showMenu: compact,
                      onMenu: compact
                          ? () => Scaffold.of(scaffoldContext).openDrawer()
                          : null,
                    ),
                    Expanded(child: child),
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

String dashboardTitleFor(String location) {
  if (location == '/ticketing' || location == '/') return 'Dashboard';
  if (location.startsWith('/ticketing/tickets/')) {
    final id = location.split('/').last;
    return 'Ticket: $id';
  }
  if (location == '/ticketing/new') return 'Add Ticket';
  if (location == '/ticketing/all') return 'All Tickets';
  if (location == '/ticketing/open') return 'Open Tickets';
  if (location == '/ticketing/pending') return 'Pending Tickets';
  if (location == '/ticketing/resolved') return 'Resolved Tickets';
  if (location == '/ticketing/priority') return 'Priority Tickets';
  if (location == '/ticketing/config') return 'Config';
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
