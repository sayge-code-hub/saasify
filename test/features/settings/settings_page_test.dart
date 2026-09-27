import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/settings/presentation/bloc/company_logo_cubit.dart';
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
  testWidgets('settings shows company logo upload controls', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final logo = CompanyLogoCubit(persist: false);
    addTearDown(logo.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: logo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: SettingsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Company logo'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-logo-upload')), findsOneWidget);
    expect(find.text('Upload logo'), findsOneWidget);
    expect(find.byKey(const ValueKey('company-logo-placeholder')), findsOneWidget);

    logo.setBytes(_tinyPng);
    await tester.pumpAndSettle();

    expect(find.text('Change logo'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-logo-remove')), findsOneWidget);
    expect(find.byKey(const ValueKey('company-logo-image')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('settings-logo-remove')));
    await tester.pumpAndSettle();
    expect(logo.state, isNull);
    expect(find.text('Upload logo'), findsOneWidget);
  });
}
