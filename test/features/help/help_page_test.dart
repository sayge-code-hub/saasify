import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/help/presentation/pages/help_page.dart';

void main() {
  testWidgets('help page shows three support tiles', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: HelpPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Raise a bug'), findsOneWidget);
    expect(find.text('Contact us'), findsOneWidget);
    expect(find.text('New feature request'), findsOneWidget);
    expect(find.byKey(const ValueKey('help-tile-bug')), findsOneWidget);
    expect(find.byKey(const ValueKey('help-tile-contact')), findsOneWidget);
    expect(find.byKey(const ValueKey('help-tile-feature')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('help-tile-bug')));
    await tester.pumpAndSettle();
    expect(find.text('Submit bug'), findsOneWidget);
  });
}
