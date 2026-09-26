import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/app/router/app_router.dart';
import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_config_list_page.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_config_page.dart';

void main() {
  testWidgets('router opens config list page for /config/applications', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      delay: Duration.zero,
      persistSession: false,
      initialState: const AuthAuthenticated(
        AuthUser(id: 'a', name: 'Admin', email: 'a@b.c'),
      ),
    );
    final tickets = TicketListCubit();
    final config = TicketConfigCubit();
    final shell = ShellCubit();
    final refresh = AuthRouterRefresh(auth);
    final router = createAppRouter(authCubit: auth, refreshListenable: refresh);
    addTearDown(auth.close);
    addTearDown(tickets.close);
    addTearDown(config.close);
    addTearDown(shell.close);
    addTearDown(refresh.dispose);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: auth),
          BlocProvider.value(value: tickets),
          BlocProvider.value(value: config),
          BlocProvider.value(value: shell),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/ticketing/config');
    await tester.pumpAndSettle();
    expect(find.byType(TicketConfigPage), findsOneWidget);

    router.go('/ticketing/config/applications');
    await tester.pumpAndSettle();
    expect(find.byType(TicketConfigListPage), findsOneWidget);
    expect(find.text('Add Application'), findsOneWidget);
    expect(find.byType(TicketConfigPage), findsNothing);
  });
}
