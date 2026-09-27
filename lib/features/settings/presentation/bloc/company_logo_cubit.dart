import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/settings/data/company_logo_store.dart';

/// Holds the tenant company logo bytes shown in the sidebar brand slot.
class CompanyLogoCubit extends Cubit<Uint8List?> {
  CompanyLogoCubit({
    Uint8List? initial,
    this.persist = true,
  }) : super(initial ?? (persist ? CompanyLogoStore.read() : null));

  final bool persist;

  void setBytes(Uint8List bytes) {
    emit(bytes);
    if (persist) CompanyLogoStore.write(bytes);
  }

  void clear() {
    emit(null);
    if (persist) CompanyLogoStore.clear();
  }
}
