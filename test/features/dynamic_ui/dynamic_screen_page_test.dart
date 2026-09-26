import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/app/app.dart';
import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/dynamic_ui/data/mock_dynamic_screens.dart';
import 'package:saasify/features/dynamic_ui/presentation/pages/dynamic_screen_page.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

void main() {
  testWidgets('BDUI Add Ticket still renders when opened directly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      delay: Duration.zero,
      persistSession: false,
      initialState: const AuthAuthenticated(
        AuthUser(id: '1', name: 'Alex', email: 'alex@saasify.io'),
      ),
    );
    final tickets = TicketListCubit();
    addTearDown(auth.close);
    addTearDown(tickets.close);

    final router = GoRouter(
      initialLocation: '/dynamic/create-ticket',
      routes: [
        GoRoute(
          path: '/dynamic/create-ticket',
          builder: (context, state) => const DynamicScreenPage(
            screenId: MockDynamicScreens.createTicketScreenId,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: auth),
          BlocProvider.value(value: tickets),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Ticket'), findsOneWidget);
    expect(find.textContaining('Header'), findsWidgets);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Dynamic UI is hidden from sidebar', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      delay: Duration.zero,
      persistSession: false,
      initialState: const AuthAuthenticated(
        AuthUser(id: '1', name: 'Alex', email: 'alex@saasify.io'),
      ),
    );
    addTearDown(auth.close);

    await tester.pumpWidget(SaasifyApp(authCubit: auth));
    await tester.pumpAndSettle();

    expect(find.text('Dynamic UI'), findsNothing);
    expect(find.text('BDUI Add Ticket'), findsNothing);
    expect(find.text('Ticketing'), findsOneWidget);
  });
}
