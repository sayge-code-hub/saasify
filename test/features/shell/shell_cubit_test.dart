import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';

void main() {
  group('ShellCubit', () {
    blocTest<ShellCubit, ShellState>(
      'starts at index 0',
      build: ShellCubit.new,
      expect: () => <ShellState>[],
      verify: (cubit) => expect(cubit.state.selectedIndex, 0),
    );

    blocTest<ShellCubit, ShellState>(
      'selectIndex emits when index changes',
      build: ShellCubit.new,
      act: (cubit) => cubit.selectIndex(1),
      expect: () => const <ShellState>[ShellState(selectedIndex: 1)],
    );

    blocTest<ShellCubit, ShellState>(
      'ignores out-of-range index',
      build: ShellCubit.new,
      act: (cubit) => cubit.selectIndex(99),
      expect: () => <ShellState>[],
      verify: (cubit) => expect(cubit.state.selectedIndex, 0),
    );

    blocTest<ShellCubit, ShellState>(
      'selectLocation maps path to index',
      build: ShellCubit.new,
      act: (cubit) => cubit.selectLocation('/'),
      expect: () => <ShellState>[],
      verify: (cubit) {
        expect(cubit.state.selectedIndex, 0);
        expect(cubit.state.selected.label, 'Home');
      },
    );
  });
}
