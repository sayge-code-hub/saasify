import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';

import 'package:saasify/features/settings/presentation/bloc/company_logo_cubit.dart';

void main() {
  final bytes = Uint8List.fromList([1, 2, 3, 4]);

  blocTest<CompanyLogoCubit, Uint8List?>(
    'setBytes emits logo bytes',
    build: () => CompanyLogoCubit(persist: false),
    act: (cubit) => cubit.setBytes(bytes),
    expect: () => [bytes],
  );

  blocTest<CompanyLogoCubit, Uint8List?>(
    'clear emits null',
    build: () => CompanyLogoCubit(persist: false, initial: bytes),
    act: (cubit) => cubit.clear(),
    expect: () => [null],
  );
}
