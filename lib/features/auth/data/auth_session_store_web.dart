import 'dart:convert';

import 'package:web/web.dart' as web;

/// Persists mock auth in sessionStorage so path deep-links survive reloads.
abstract final class AuthSessionStore {
  static const _key = 'saasify_auth_session';

  static Map<String, String>? read() {
    final raw = web.window.sessionStorage.getItem(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final id = decoded['id']?.toString();
      final name = decoded['name']?.toString();
      final email = decoded['email']?.toString();
      final role = decoded['role']?.toString() ?? 'Admin';
      if (id == null || name == null || email == null) return null;
      return {'id': id, 'name': name, 'email': email, 'role': role};
    } catch (_) {
      return null;
    }
  }

  static void write({
    required String id,
    required String name,
    required String email,
    required String role,
  }) {
    web.window.sessionStorage.setItem(
      _key,
      jsonEncode({
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      }),
    );
  }

  static void clear() {
    web.window.sessionStorage.removeItem(_key);
  }
}
