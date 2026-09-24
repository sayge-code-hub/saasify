import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/auth/presentation/pages/login_page.dart';
import 'package:saasify/features/overview/presentation/pages/overview_page.dart';
import 'package:saasify/features/settings/presentation/pages/settings_page.dart';
import 'package:saasify/features/shell/presentation/pages/shell_page.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_detail_page.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_list_page.dart';

GoRouter createAppRouter({
  required AuthCubit authCubit,
  required Listenable refreshListenable,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authed = authCubit.state is AuthAuthenticated;
      final loggingIn = state.matchedLocation == '/login';

      if (!authed && !loggingIn) return '/login';
      if (authed && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ShellLocationSync(
            location: state.uri.path,
            child: ShellPage(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'overview',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: OverviewPage(),
            ),
          ),
          GoRoute(
            path: '/ticketing',
            name: 'ticketing',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: TicketListPage(),
            ),
            routes: [
              GoRoute(
                path: 'open',
                name: 'ticketing-open',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: TicketListPage(routeFilter: 'open'),
                ),
              ),
              GoRoute(
                path: 'pending',
                name: 'ticketing-pending',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: TicketListPage(routeFilter: 'pending'),
                ),
              ),
              GoRoute(
                path: 'resolved',
                name: 'ticketing-resolved',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: TicketListPage(routeFilter: 'resolved'),
                ),
              ),
              GoRoute(
                path: 'tickets/:id',
                name: 'ticket-detail',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  child: TicketDetailPage(
                    ticketId: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
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

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(this._authCubit) {
    _subscription = _authCubit.stream.listen((_) => notifyListeners());
  }

  final AuthCubit _authCubit;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
