import 'dart:convert';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Persists the uploaded company logo in localStorage (base64).
abstract final class CompanyLogoStore {
  static const _key = 'saasify_company_logo';

  static Uint8List? read() {
    final raw = web.window.localStorage.getItem(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Uint8List.fromList(base64Decode(raw));
    } catch (_) {
      return null;
    }
  }

  static void write(Uint8List bytes) {
    web.window.localStorage.setItem(_key, base64Encode(bytes));
  }

  static void clear() {
    web.window.localStorage.removeItem(_key);
  }
}
