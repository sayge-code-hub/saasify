import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/app/app.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
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

  testWidgets('ticketing list opens detail with comments and side panel', (
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
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('Attachments'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Workflow'), findsNothing);
    expect(find.textContaining('Ticket:'), findsNothing);
    expect(find.byKey(const ValueKey('header-back-all-tickets')), findsOneWidget);

    tickets.updateStatus('TCK-1042', TicketStatus.inProgress);
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
    expect(find.text('Create Ticket'), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-header')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-application')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-priority')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-bug')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-responsibility')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-equipment')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-description')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-distribution')), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    tickets.createTicket(
      subject: 'Cannot login on tablet',
      description: 'Login spinner never finishes on iPad.',
      priority: TicketPriority.high,
      application: 'Mobile App',
      distributionList: 'Support On-Call',
      responsibility: 'Taylor Reed',
      affectedEquipment: 'iPad Pro',
    );
    expect(tickets.state.tickets.first.subject, 'Cannot login on tablet');
    expect(tickets.state.tickets.first.application, 'Mobile App');
    expect(tickets.state.tickets.first.distributionList, 'Support On-Call');
    expect(tickets.state.tickets.first.responsibility, 'Taylor Reed');
  });
}
