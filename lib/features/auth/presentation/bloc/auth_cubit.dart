import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/auth/domain/auth_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// In-memory mock auth. Any non-empty email/password succeeds.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    AuthState? initialState,
    this.delay = const Duration(milliseconds: 450),
  }) : super(initialState ?? const AuthUnauthenticated());

  final Duration delay;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      emit(const AuthFailure('Email and password are required.'));
      return;
    }

    emit(const AuthAuthenticating());
    await Future<void>.delayed(delay);

    final name = trimmedEmail.contains('@')
        ? trimmedEmail.split('@').first
        : trimmedEmail;

    emit(
      AuthAuthenticated(
        AuthUser(
          id: 'admin-1',
          name: _titleCase(name),
          email: trimmedEmail,
        ),
      ),
    );
  }

  void logout() => emit(const AuthUnauthenticated());

  void clearFailure() {
    if (state is AuthFailure) {
      emit(const AuthUnauthenticated());
    }
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return 'Admin';
    return value[0].toUpperCase() + value.substring(1);
  }
}
