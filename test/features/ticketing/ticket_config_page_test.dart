import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';
import 'package:saasify/features/ticketing/presentation/pages/ticket_config_page.dart';

void main() {
  testWidgets('config page edits applications and shows SLA targets', (
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

    expect(find.text('Applications'), findsOneWidget);
    expect(find.text('Distribution lists'), findsOneWidget);
    expect(find.text('Assignees'), findsOneWidget);
    expect(find.text('Bug options'), findsOneWidget);
    expect(find.text('SLA targets'), findsOneWidget);
    expect(find.text('First response (hours)'), findsWidgets);

    await tester.enterText(find.widgetWithText(TextField, 'Add option…').first, 'Field Ops');
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();

    expect(config.state.applications, contains('Field Ops'));
    expect(find.text('Field Ops'), findsOneWidget);
  });
}
