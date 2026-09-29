import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saasify/app/app.dart';
import 'package:saasify/features/assets/presentation/bloc/pm_plan_cubit.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

void main() {
  testWidgets('PM schedule lists Charge Pump A and opens detail', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      initialState: const AuthAuthenticated(
        AuthUser(
          id: 'admin-1',
          name: 'Admin',
          email: 'admin@saasify.io',
          role: 'Admin',
        ),
      ),
      persistSession: false,
      delay: Duration.zero,
    );
    addTearDown(auth.close);

    await tester.pumpWidget(
      SaasifyApp(
        authCubit: auth,
        pmPlanCubit: PmPlanCubit(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-assets')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-assets-pm')));
    await tester.pumpAndSettle();

    expect(find.text('PM Schedule'), findsWidgets);
    expect(find.text('Charge Pump A'), findsWidgets);

    await tester.tap(find.text('PM-1001').first);
    await tester.pumpAndSettle();

    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Check vibration'), findsOneWidget);
    expect(find.byKey(const ValueKey('pm-complete')), findsOneWidget);
  });
}
