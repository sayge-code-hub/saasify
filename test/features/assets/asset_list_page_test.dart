import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saasify/app/app.dart';
import 'package:saasify/features/assets/presentation/bloc/asset_list_cubit.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

void main() {
  testWidgets('asset list shows seed assets and opens add form', (tester) async {
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
        assetListCubit: AssetListCubit(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-assets')));
    await tester.pumpAndSettle();

    expect(find.text('Asset List'), findsWidgets);
    expect(find.text('AC Fail'), findsOneWidget);
    expect(find.byKey(const ValueKey('asset-add')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('asset-add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('asset-name')), findsOneWidget);
    expect(find.byKey(const ValueKey('asset-save')), findsOneWidget);
  });
}
