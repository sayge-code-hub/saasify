import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/features/auth/domain/auth_user.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

void main() {
  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'emits failure when credentials empty',
      build: () => AuthCubit(delay: Duration.zero),
      act: (cubit) => cubit.login(email: ' ', password: ''),
      expect: () => const [
        AuthFailure('Email and password are required.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'authenticates with any non-empty credentials',
      build: () => AuthCubit(delay: Duration.zero),
      act: (cubit) => cubit.login(
        email: 'admin@saasify.io',
        password: 'secret',
      ),
      expect: () => const [
        AuthAuthenticating(),
        AuthAuthenticated(
          AuthUser(
            id: 'admin-1',
            name: 'Admin',
            email: 'admin@saasify.io',
          ),
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'logout returns to unauthenticated',
      build: () => AuthCubit(
        delay: Duration.zero,
        initialState: const AuthAuthenticated(
          AuthUser(id: '1', name: 'A', email: 'a@b.c'),
        ),
      ),
      act: (cubit) => cubit.logout(),
      expect: () => const [AuthUnauthenticated()],
    );
  });
}
