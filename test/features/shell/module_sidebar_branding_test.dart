import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/core/widgets/app_logo.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/settings/presentation/bloc/company_logo_cubit.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';
import 'package:saasify/features/shell/presentation/widgets/module_sidebar.dart';

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
  testWidgets('sidebar shows company placeholder and Saasify footer logo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final logo = CompanyLogoCubit(persist: false);
    final shell = ShellCubit();
    final auth = AuthCubit(
      delay: Duration.zero,
      persistSession: false,
      initialState: const AuthAuthenticated(
        AuthUser(id: '1', name: 'Alex', email: 'alex@saasify.io'),
      ),
    );
    addTearDown(logo.close);
    addTearDown(shell.close);
    addTearDown(auth.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: logo),
          BlocProvider.value(value: shell),
          BlocProvider.value(value: auth),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ModuleSidebar()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('company-logo-placeholder')), findsOneWidget);
    expect(find.byKey(const ValueKey('sidebar-saasify-logo')), findsOneWidget);
    expect(find.byType(AppLogoWordmark), findsOneWidget);
    expect(find.textContaining('Powered by'), findsOneWidget);
    expect(find.byKey(const ValueKey('app-version-link')), findsOneWidget);

    final wordmark = tester.widget<AppLogoWordmark>(
      find.byKey(const ValueKey('sidebar-saasify-logo')),
    );
    expect(wordmark.height, lessThanOrEqualTo(14));
  });

  testWidgets('sidebar shows uploaded company logo bytes', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final logo = CompanyLogoCubit(persist: false, initial: _tinyPng);
    final shell = ShellCubit();
    final auth = AuthCubit(
      delay: Duration.zero,
      persistSession: false,
      initialState: const AuthAuthenticated(
        AuthUser(id: '1', name: 'Alex', email: 'alex@saasify.io'),
      ),
    );
    addTearDown(logo.close);
    addTearDown(shell.close);
    addTearDown(auth.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: logo),
          BlocProvider.value(value: shell),
          BlocProvider.value(value: auth),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ModuleSidebar()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('company-logo-image')), findsOneWidget);
    expect(find.byKey(const ValueKey('company-logo-placeholder')), findsNothing);
  });
}
