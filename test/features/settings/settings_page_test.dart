import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/settings/presentation/bloc/company_logo_cubit.dart';
import 'package:saasify/features/settings/presentation/bloc/workspace_settings_cubit.dart';
import 'package:saasify/features/settings/presentation/pages/settings_page.dart';

/// Minimal valid 1x1 PNG.
final Uint8List _tinyPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  testWidgets('settings shows logo and editable workspace sections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final logo = CompanyLogoCubit(persist: false);
    final workspace = WorkspaceSettingsCubit();
    addTearDown(logo.close);
    addTearDown(workspace.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: logo),
          BlocProvider.value(value: workspace),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: SettingsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Company logo'), findsOneWidget);
    expect(find.text('Workspace profile'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-logo-upload')), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-profile-edit')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('settings-profile-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('settings-workspace-name')),
      'Northwind Ops',
    );
    await tester.tap(find.byKey(const ValueKey('settings-profile-save')));
    await tester.pumpAndSettle();
    expect(workspace.state.workspaceName, 'Northwind Ops');

    logo.setBytes(_tinyPng);
    await tester.pumpAndSettle();
    expect(find.text('Change logo'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('settings-logo-remove')));
    await tester.pumpAndSettle();
    expect(logo.state, isNull);
  });
}
