import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/app/app.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

void main() {
  testWidgets('unauthenticated users land on login', (tester) async {
    await tester.pumpWidget(const SaasifyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in to the admin workspace'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('login enters ticketing dashboard with sidebar modules', (
    tester,
  ) async {
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

    expect(find.text('Overview'), findsNothing);
    expect(find.text('Ticketing'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Add Ticket'), findsOneWidget);
    expect(find.text('Ticket by status'), findsOneWidget);
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

    await tester.tap(find.text('All Tickets'));
    await tester.pumpAndSettle();

    expect(find.text('All Tickets'), findsWidgets);
    expect(find.textContaining('TCK-'), findsWidgets);

    await tester.tap(find.text('TCK-1042').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Cannot reset password'), findsOneWidget);
    expect(find.text('Workflow'), findsOneWidget);

    await tester.tap(find.text('Mark in progress'));
    await tester.pumpAndSettle();

    expect(tickets.state.byId('TCK-1042')!.status.name, 'inProgress');
  });

  testWidgets('sidebar keys navigate and add ticket creates a case', (
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

    expect(find.text('Ticket by status'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-ticketing-open')));
    await tester.pumpAndSettle();
    expect(find.text('Open Tickets'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('nav-ticketing-new')));
    await tester.pumpAndSettle();
    expect(find.text('Add new ticket'), findsOneWidget);

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.at(0), 'Cannot login on tablet');
    await tester.enterText(fields.at(1), 'Login spinner never finishes on iPad.');
    await tester.enterText(fields.at(2), 'Taylor Reed');
    await tester.enterText(fields.at(3), 'taylor@example.com');
    await tester.tap(find.text('Create case'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cannot login on tablet'), findsOneWidget);
    expect(tickets.state.tickets.first.subject, 'Cannot login on tablet');
  });
}
