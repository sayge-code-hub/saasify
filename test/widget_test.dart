import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/app/app.dart';
import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

void main() {
  testWidgets('unauthenticated users land on login', (tester) async {
    await tester.pumpWidget(const SaasifyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in to the admin workspace'), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);
  });

  testWidgets('login enters overview with module sidebar', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(delay: Duration.zero);
    addTearDown(auth.close);

    await tester.pumpWidget(SaasifyApp(authCubit: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Ticketing'), findsOneWidget);
    expect(find.text('Open tickets'), findsNothing);
  });

  testWidgets('ticketing list opens detail and advances workflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      delay: Duration.zero,
      initialState: const AuthAuthenticated(
        AuthUser(id: '1', name: 'Alex', email: 'alex@saasify.io'),
      ),
    );
    final tickets = TicketListCubit();
    addTearDown(auth.close);
    addTearDown(tickets.close);

    await tester.pumpWidget(
      SaasifyApp(authCubit: auth, ticketListCubit: tickets),
    );
    await tester.pumpAndSettle();

    // Expand already open; navigate via submodule label.
    await tester.tap(find.text('All tickets'));
    await tester.pumpAndSettle();

    expect(find.text('All tickets'), findsWidgets);
    expect(find.textContaining('TCK-'), findsWidgets);

    await tester.tap(find.text('TCK-1042').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Cannot reset password'), findsOneWidget);
    expect(find.text('Workflow'), findsOneWidget);

    await tester.tap(find.text('Mark in progress'));
    await tester.pumpAndSettle();

    expect(tickets.state.byId('TCK-1042')!.status.name, 'inProgress');
  });

  testWidgets('overview CTA and sidebar keys navigate to ticketing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      delay: Duration.zero,
      initialState: const AuthAuthenticated(
        AuthUser(id: '1', name: 'Alex', email: 'alex@saasify.io'),
      ),
    );
    addTearDown(auth.close);

    await tester.pumpWidget(SaasifyApp(authCubit: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open ticketing'));
    await tester.pumpAndSettle();
    expect(find.text('Triage and resolve customer support requests.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-ticketing-open')));
    await tester.pumpAndSettle();
    expect(find.text('Open tickets'), findsOneWidget);
  });
}
