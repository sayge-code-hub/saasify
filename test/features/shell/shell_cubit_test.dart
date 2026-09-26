import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';

void main() {
  group('ShellCubit', () {
    blocTest<ShellCubit, ShellState>(
      'setLocation expands ticketing for ticket paths',
      build: ShellCubit.new,
      act: (cubit) => cubit.setLocation('/ticketing/all'),
      verify: (cubit) {
        expect(cubit.state.location, '/ticketing/all');
        expect(cubit.state.expandedModuleIds, contains('ticketing'));
      },
    );

    blocTest<ShellCubit, ShellState>(
      'toggleModule collapses and expands',
      build: ShellCubit.new,
      act: (cubit) {
        cubit.toggleModule('ticketing');
        cubit.toggleModule('ticketing');
      },
      verify: (cubit) {
        expect(cubit.state.expandedModuleIds, contains('ticketing'));
      },
    );
  });
}
