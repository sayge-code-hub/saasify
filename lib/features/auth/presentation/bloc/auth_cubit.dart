import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/auth/data/auth_session_store.dart';
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

/// Mock auth. Any non-empty email/password succeeds.
/// On web, the session is restored from sessionStorage across reloads.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    AuthState? initialState,
    this.delay = const Duration(milliseconds: 450),
    this.persistSession = true,
  }) : super(initialState ?? _restore(persistSession));

  final Duration delay;
  final bool persistSession;

  static AuthState _restore(bool persistSession) {
    if (!persistSession) return const AuthUnauthenticated();
    final saved = AuthSessionStore.read();
    if (saved == null) return const AuthUnauthenticated();
    return AuthAuthenticated(
      AuthUser(
        id: saved['id']!,
        name: saved['name']!,
        email: saved['email']!,
        role: saved['role'] ?? 'Admin',
      ),
    );
  }

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

    final user = AuthUser(
      id: 'admin-1',
      name: _titleCase(name),
      email: trimmedEmail,
    );
    if (persistSession) {
      AuthSessionStore.write(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      );
    }
    emit(AuthAuthenticated(user));
  }

  void logout() {
    if (persistSession) AuthSessionStore.clear();
    emit(const AuthUnauthenticated());
  }

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
