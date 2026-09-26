import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_config_list_page.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_config_page.dart';

void main() {
  testWidgets('config hub shows searchable sections and edit actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final config = TicketConfigCubit();
    addTearDown(config.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: config,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: TicketConfigPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Config'), findsOneWidget);
    expect(find.text('Applications'), findsOneWidget);
    expect(find.text('Distribution lists'), findsOneWidget);
    expect(find.text('Assignees'), findsOneWidget);
    expect(find.text('Bug options'), findsOneWidget);
    expect(find.text('SLA targets'), findsOneWidget);
    expect(find.text('Edit'), findsWidgets);
    expect(find.text('Add option…'), findsNothing);
    expect(find.text('Search config sections…'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'assignee');
    await tester.pumpAndSettle();

    expect(find.text('Assignees'), findsOneWidget);
    expect(find.text('Applications'), findsNothing);
  });

  testWidgets('config list editor confirms add and saves', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final config = TicketConfigCubit();
    addTearDown(config.close);

    final router = GoRouter(
      initialLocation: '/ticketing/config/applications',
      routes: [
        GoRoute(
          path: '/ticketing/config',
          builder: (context, state) => const Scaffold(
            body: TicketConfigPage(),
          ),
          routes: [
            GoRoute(
              path: ':kind',
              builder: (context, state) => const Scaffold(
                body: TicketConfigListPage(
                  kind: TicketConfigListKind.applications,
                ),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: config,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Applications'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('config-list-add')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Field Ops');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Add application?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Field Ops'), findsOneWidget);
    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(config.state.applications, isNot(contains('Field Ops')));

    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
    expect(find.text('Save ${'Applications'.toLowerCase()}?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await tester.pumpAndSettle();

    expect(config.state.applications, contains('Field Ops'));
  });

  testWidgets('config list editor warns before discarding dirty edits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final config = TicketConfigCubit();
    addTearDown(config.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: config,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: TicketConfigListPage(
              kind: TicketConfigListKind.applications,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('config-list-add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Temp App');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('config-list-back')));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Temp App'), findsOneWidget);
  });
}
