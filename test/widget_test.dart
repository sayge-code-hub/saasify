import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/app/app.dart';
import 'package:saasify/core/constants/app_constants.dart';

void main() {
  testWidgets('app boots to home with brand', (tester) async {
    await tester.pumpWidget(SaasifyApp());
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsWidgets);
    expect(find.textContaining('Foundation ready'), findsOneWidget);
  });

  testWidgets('compact layout shows bottom navigation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(SaasifyApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('expanded layout shows navigation rail', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(SaasifyApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('navigates to settings from bottom bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(SaasifyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Workspace preferences will land here'),
      findsOneWidget,
    );
  });
}
