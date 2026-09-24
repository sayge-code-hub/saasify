import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/features/home/presentation/pages/home_page.dart';
import 'package:saasify/features/settings/presentation/pages/settings_page.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';
import 'package:saasify/features/shell/presentation/pages/shell_page.dart';

/// Central route table. Feature pages must not define their own graphs.
GoRouter createAppRouter({GlobalKey<NavigatorState>? navigatorKey}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return _ShellLocationSync(
            location: state.uri.path,
            child: ShellPage(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Keeps [ShellCubit] aligned when the router location changes.
class _ShellLocationSync extends StatefulWidget {
  const _ShellLocationSync({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<_ShellLocationSync> createState() => _ShellLocationSyncState();
}

class _ShellLocationSyncState extends State<_ShellLocationSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ShellCubit>().selectLocation(widget.location);
    });
  }

  @override
  void didUpdateWidget(covariant _ShellLocationSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      context.read<ShellCubit>().selectLocation(widget.location);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
