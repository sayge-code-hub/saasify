import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/ticketing/data/mock_tickets.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_detail_page.dart';

void main() {
  testWidgets('ticket detail shows compact chips card and assignee change UX', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      delay: Duration.zero,
      persistSession: false,
      initialState: const AuthAuthenticated(
        AuthUser(id: 'admin-1', name: 'Admin', email: 'admin@saasify.io'),
      ),
    );
    final tickets = TicketListCubit(seed: MockTickets.createCatalog());
    final config = TicketConfigCubit();
    addTearDown(auth.close);
    addTearDown(tickets.close);
    addTearDown(config.close);

    final router = GoRouter(
      initialLocation: '/ticketing/tickets/TCK-1038',
      routes: [
        GoRoute(
          path: '/ticketing/tickets/:id',
          builder: (context, state) => Scaffold(
            body: TicketDetailPage(
              ticketId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: '/ticketing/all',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: auth),
          BlocProvider.value(value: tickets),
          BlocProvider.value(value: config),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('PRIORITY'), findsOneWidget);
    expect(find.text('SLA'), findsWidgets);
    expect(find.text('TAGS'), findsOneWidget);
    expect(find.text('First response'), findsOneWidget);
    expect(find.text('Resolution'), findsOneWidget);
    expect(find.text('Attachments'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('blank-invoice-aug.pdf'), findsOneWidget);
    expect(find.text('Ticket created'), findsWidgets);
    expect(find.text('Assigned'), findsWidgets);
    expect(find.text('Status changed'), findsWidgets);
    expect(find.text('Invoice PDF downloads corrupted'), findsOneWidget);

    // Compact assignee display by default (no dropdown until Change).
    expect(find.byKey(const ValueKey('ticket-assignee-display')), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-assignee-change')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-assignee')), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('ticket-assignee-change')),
    );
    await tester.tap(find.byKey(const ValueKey('ticket-assignee-change')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('ticket-assignee')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ticket-assignee')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riley Nguyen').last);
    await tester.pumpAndSettle();

    expect(tickets.state.byId('TCK-1038')!.assigneeName, 'Riley Nguyen');
    expect(
      tickets.state.byId('TCK-1038')!.events.last.detail,
      'Assigned to Riley Nguyen',
    );
    expect(find.byKey(const ValueKey('ticket-assignee-display')), findsOneWidget);
    expect(find.byKey(const ValueKey('ticket-assignee')), findsNothing);
  });
}
