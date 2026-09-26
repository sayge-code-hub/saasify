/// Non-web stub — session is not persisted across reloads.
abstract final class AuthSessionStore {
  static Map<String, String>? read() => null;

  static void write({
    required String id,
    required String name,
    required String email,
    required String role,
  }) {}

  static void clear() {}
}
