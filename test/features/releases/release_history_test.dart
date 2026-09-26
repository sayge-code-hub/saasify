import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/app/app.dart';
import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

void main() {
  testWidgets('login shows powered by and version opens releases', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SaasifyApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Powered by'), findsOneWidget);
    expect(find.text(AppConstants.saygeLabel), findsOneWidget);
    expect(find.text(AppConstants.appVersionLabel), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('app-version-link')));
    await tester.pumpAndSettle();

    expect(find.text('Release history'), findsOneWidget);
    expect(find.textContaining('v1.0.0'), findsWidgets);
    expect(find.text('Feature'), findsWidgets);
  });

  testWidgets('sidebar version opens release history when signed in', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      delay: Duration.zero,
      persistSession: false,
      initialState: const AuthAuthenticated(
        AuthUser(id: '1', name: 'Alex', email: 'alex@saasify.io'),
      ),
    );
    addTearDown(auth.close);

    await tester.pumpWidget(SaasifyApp(authCubit: auth));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-version-link')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('app-version-link')));
    await tester.tap(find.byKey(const ValueKey('app-version-link')));
    await tester.pumpAndSettle();

    expect(find.text('Release history'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
  });
}
