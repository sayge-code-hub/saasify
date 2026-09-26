import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/app/app.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

void main() {
  testWidgets('BDUI Add Ticket renders from mock JSON', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
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

    expect(find.text('Dynamic UI'), findsOneWidget);
    await tester.tap(find.text('BDUI Add Ticket'));
    await tester.pumpAndSettle();

    expect(find.text('Create Ticket'), findsOneWidget);
    expect(find.textContaining('Header'), findsWidgets);
    expect(find.textContaining('Application'), findsWidgets);
    expect(find.textContaining('Channel'), findsWidgets);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Existing hard-coded Add Ticket route still available in nav.
    expect(find.text('Add Ticket'), findsWidgets);
  });
}
