import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_theme.dart';
import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/profile/presentation/pages/profile_page.dart';
import 'package:saasify/features/shell/presentation/widgets/dashboard_header.dart';

void main() {
  testWidgets('profile menu offers Profile and Logout; help stays ink color', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthCubit(
      delay: Duration.zero,
      persistSession: false,
      initialState: const AuthAuthenticated(
        AuthUser(id: '1', name: 'Admin', email: 'admin@saasify.io'),
      ),
    );
    addTearDown(auth.close);

    final router = GoRouter(
      initialLocation: '/help',
      routes: [
        GoRoute(
          path: '/help',
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                DashboardHeader(title: '', userName: 'Admin'),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const Scaffold(body: ProfilePage()),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: auth,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('header-logout')), findsNothing);
    final helpIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const ValueKey('header-help')),
        matching: find.byType(Icon),
      ),
    );
    expect(helpIcon.icon, Icons.help_outline);
    expect(helpIcon.color, AppColors.ink);

    await tester.tap(find.byKey(const ValueKey('header-profile-menu')));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);
    expect(find.byKey(const ValueKey('profile-name')), findsOneWidget);
  });
}
