import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';

void main() {
  group('TicketConfigCubit', () {
    blocTest<TicketConfigCubit, dynamic>(
      'adds and removes application options',
      build: TicketConfigCubit.new,
      act: (cubit) {
        cubit.addListItem(TicketConfigListKind.applications, 'Field Ops');
        cubit.removeListItem(TicketConfigListKind.applications, 'Billing');
      },
      verify: (cubit) {
        expect(cubit.state.applications, contains('Field Ops'));
        expect(cubit.state.applications, isNot(contains('Billing')));
      },
    );

    blocTest<TicketConfigCubit, dynamic>(
      'updates SLA hours for a priority',
      build: TicketConfigCubit.new,
      act: (cubit) {
        cubit.setFirstResponseHours(TicketPriority.urgent, 0.5);
        cubit.setResolutionHours(TicketPriority.urgent, 2);
      },
      verify: (cubit) {
        final target = cubit.state.slaFor(TicketPriority.urgent);
        expect(target.firstResponse, const Duration(minutes: 30));
        expect(target.resolution, const Duration(hours: 2));
      },
    );

    blocTest<TicketConfigCubit, dynamic>(
      'keeps at least one enabled priority',
      build: TicketConfigCubit.new,
      act: (cubit) {
        for (final priority in TicketPriority.values) {
          cubit.togglePriority(priority, false);
        }
      },
      verify: (cubit) {
        expect(cubit.state.enabledPriorities, isNotEmpty);
      },
    );
  });
}