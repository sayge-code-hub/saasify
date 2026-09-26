import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/ticketing/data/mock_tickets.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_detail_page.dart';

void main() {
  testWidgets('ticket detail shows 70/30 details and activity ledger', (
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
    addTearDown(auth.close);
    addTearDown(tickets.close);

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
    expect(find.text('Attachments'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('blank-invoice-aug.pdf'), findsOneWidget);
    expect(find.text('Ticket created'), findsWidgets);
    expect(find.text('Assigned'), findsWidgets);
    expect(find.text('Status changed'), findsWidgets);
    expect(find.text('Invoice PDF downloads corrupted'), findsOneWidget);
  });
}
