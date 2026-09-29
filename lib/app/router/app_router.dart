import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/features/assets/presentation/pages/asset_detail_page.dart';
import 'package:saasify/features/assets/presentation/pages/asset_form_page.dart';
import 'package:saasify/features/assets/presentation/pages/asset_list_page.dart';
import 'package:saasify/features/assets/presentation/pages/asset_tree_page.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/auth/presentation/pages/login_page.dart';
import 'package:saasify/features/dynamic_ui/data/mock_dynamic_screens.dart';
import 'package:saasify/features/dynamic_ui/presentation/pages/dynamic_screen_page.dart';
import 'package:saasify/features/help/domain/help_topics.dart';
import 'package:saasify/features/help/presentation/pages/help_page.dart';
import 'package:saasify/features/help/presentation/pages/help_topic_page.dart';
import 'package:saasify/features/overview/presentation/pages/overview_page.dart';
import 'package:saasify/features/profile/presentation/pages/profile_page.dart';
import 'package:saasify/features/releases/presentation/pages/release_history_page.dart';
import 'package:saasify/features/settings/presentation/pages/settings_page.dart';
import 'package:saasify/features/shell/presentation/pages/shell_page.dart';
import 'package:saasify/features/ticketing/domain/ticket_config_lists.dart';
import 'package:saasify/features/ticketing/presentation/pages/create_ticket_page.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_config_list_page.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_config_page.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_detail_page.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_list_page.dart';

GoRouter createAppRouter({
  required AuthCubit authCubit,
  required Listenable refreshListenable,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/ticketing',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authed = authCubit.state is AuthAuthenticated;
      final loggingIn = state.matchedLocation == '/login';
      final atRoot = state.matchedLocation == '/';
      final onReleases = state.matchedLocation == '/releases';

      if (!authed && !loggingIn && !onReleases) return '/login';
      if (authed && loggingIn) return '/ticketing';
      if (authed && atRoot) return '/ticketing';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/releases',
        name: 'releases',
        builder: (context, state) => const ReleaseHistoryPage(),
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
            redirect: (context, state) => '/ticketing',
          ),
          GoRoute(
            path: '/ticketing',
            name: 'ticketing',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: OverviewPage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'ticketing-new',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: CreateTicketPage(),
                ),
              ),
              GoRoute(
                path: 'all',
                name: 'ticketing-all',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: TicketListPage(),
                ),
              ),
              GoRoute(
                path: 'config',
                name: 'ticketing-config',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: TicketConfigPage(),
                ),
              ),
              GoRoute(
                path: 'config/:kind',
                name: 'ticketing-config-list',
                pageBuilder: (context, state) {
                  final kind = TicketConfigListKindX.tryParse(
                    state.pathParameters['kind'] ?? '',
                  );
                  if (kind == null) {
                    return const NoTransitionPage<void>(
                      child: TicketConfigPage(),
                    );
                  }
                  return NoTransitionPage<void>(
                    child: TicketConfigListPage(kind: kind),
                  );
                },
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
            path: '/assets',
            name: 'assets',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: AssetListPage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'assets-new',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: AssetFormPage(),
                ),
              ),
              GoRoute(
                path: 'tree',
                name: 'assets-tree',
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: AssetTreePage(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: 'asset-detail',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  child: AssetDetailPage(
                    assetId: state.pathParameters['id']!,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'asset-edit',
                    pageBuilder: (context, state) => NoTransitionPage<void>(
                      child: AssetEditPage(
                        assetId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
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
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: ProfilePage(),
            ),
          ),
          GoRoute(
            path: '/help',
            name: 'help',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: HelpPage(),
            ),
            routes: [
              GoRoute(
                path: ':topic',
                name: 'help-topic',
                pageBuilder: (context, state) {
                  final topic = HelpTopicX.tryParse(
                    state.pathParameters['topic'] ?? '',
                  );
                  if (topic == null) {
                    return const NoTransitionPage<void>(
                      child: HelpPage(),
                    );
                  }
                  return NoTransitionPage<void>(
                    child: HelpTopicPage(topic: topic),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/dynamic/create-ticket',
            name: 'dynamic-create-ticket',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: DynamicScreenPage(
                screenId: MockDynamicScreens.createTicketScreenId,
              ),
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
