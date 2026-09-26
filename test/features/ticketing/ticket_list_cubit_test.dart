import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

void main() {
  final seed = [
    Ticket(
      id: 'TCK-1',
      subject: 'Login broken',
      description: 'Cannot sign in',
      status: TicketStatus.open,
      priority: TicketPriority.high,
      customerName: 'Ada',
      customerEmail: 'ada@example.com',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
      messages: const [],
    ),
    Ticket(
      id: 'TCK-2',
      subject: 'Billing PDF',
      description: 'Export fails',
      status: TicketStatus.pending,
      priority: TicketPriority.urgent,
      customerName: 'Bob',
      customerEmail: 'bob@example.com',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 3),
      messages: const [],
    ),
  ];

  group('TicketListCubit', () {
    blocTest<TicketListCubit, TicketListState>(
      'filters by status and query',
      build: () => TicketListCubit(seed: seed),
      act: (cubit) {
        cubit.setStatusFilter(TicketStatus.open);
        cubit.setQuery('login');
      },
      expect: () => [
        isA<TicketListState>()
            .having((s) => s.statusFilter, 'status', TicketStatus.open)
            .having((s) => s.visible, 'visible', hasLength(1)),
        isA<TicketListState>()
            .having((s) => s.query, 'query', 'login')
            .having((s) => s.visible.single.id, 'id', 'TCK-1'),
      ],
    );

    blocTest<TicketListCubit, TicketListState>(
      'updates status and appends reply',
      build: () => TicketListCubit(seed: seed),
      act: (cubit) {
        cubit.updateStatus('TCK-1', TicketStatus.inProgress);
        cubit.addReply(
          ticketId: 'TCK-1',
          body: 'Looking into this',
          agentName: 'Alex',
        );
      },
      verify: (cubit) {
        final ticket = cubit.state.byId('TCK-1')!;
        expect(ticket.status, TicketStatus.inProgress);
        expect(ticket.messages, hasLength(1));
        expect(ticket.messages.single.body, 'Looking into this');
      },
    );

    blocTest<TicketListCubit, TicketListState>(
      'applyRouteFilter maps segments',
      build: () => TicketListCubit(seed: seed),
      act: (cubit) => cubit.applyRouteFilter('pending'),
      verify: (cubit) {
        expect(cubit.state.statusFilter, TicketStatus.pending);
        expect(cubit.state.visible.single.id, 'TCK-2');
      },
    );

    blocTest<TicketListCubit, TicketListState>(
      'priority route shows urgent and high',
      build: () => TicketListCubit(seed: seed),
      act: (cubit) => cubit.applyRouteFilter('priority'),
      verify: (cubit) {
        expect(cubit.state.priorityQueue, isTrue);
        expect(cubit.state.visible, hasLength(2));
      },
    );

    blocTest<TicketListCubit, TicketListState>(
      'createTicket prepends an open case',
      build: () => TicketListCubit(seed: seed),
      act: (cubit) => cubit.createTicket(
        subject: 'New case',
        description: 'Details here',
        customerName: 'Casey',
        customerEmail: 'casey@example.com',
        priority: TicketPriority.urgent,
      ),
      verify: (cubit) {
        final created = cubit.state.tickets.first;
        expect(created.subject, 'New case');
        expect(created.status, TicketStatus.open);
        expect(created.id, 'TCK-3');
      },
    );
  });
}
