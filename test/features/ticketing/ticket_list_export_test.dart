import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/ticketing/data/mock_tickets.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_list_page.dart';

void main() {
  testWidgets('Export opens a centered dialog with Excel, PDF, and Raw JSON', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tickets = TicketListCubit(seed: MockTickets.createCatalog());
    addTearDown(tickets.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: tickets,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: TicketListPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Export'), findsWidgets);
    expect(find.text('Choose a format for the current ticket list.'), findsOneWidget);
    expect(find.text('Excel'), findsOneWidget);
    expect(find.text('Spreadsheet (.xlsx)'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Document (.pdf)'), findsOneWidget);
    expect(find.text('Raw JSON'), findsOneWidget);
    expect(find.text('Structured data (.json)'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Raw JSON'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(
      find.textContaining('as Raw JSON (mock download)'),
      findsOneWidget,
    );
  });

  testWidgets('Export dialog Cancel dismisses without a snackbar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tickets = TicketListCubit(seed: MockTickets.createCatalog());
    addTearDown(tickets.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: tickets,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: TicketListPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.textContaining('mock download'), findsNothing);
  });
}
