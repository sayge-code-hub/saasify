import 'dart:typed_data';

/// Non-web stub — company logo is not persisted across reloads.
abstract final class CompanyLogoStore {
  static Uint8List? read() => null;

  static void write(Uint8List bytes) {}

  static void clear() {}
}
