import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/ticketing/data/mock_tickets.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';

class TicketListState extends Equatable {
  const TicketListState({
    required this.tickets,
    this.query = '',
    this.statusFilter,
    this.priorityFilter,
  });

  final List<Ticket> tickets;
  final String query;
  final TicketStatus? statusFilter;
  final TicketPriority? priorityFilter;

  List<Ticket> get visible {
    final q = query.trim().toLowerCase();
    return tickets.where((ticket) {
      if (statusFilter != null && ticket.status != statusFilter) {
        return false;
      }
      if (priorityFilter != null && ticket.priority != priorityFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return ticket.id.toLowerCase().contains(q) ||
          ticket.subject.toLowerCase().contains(q) ||
          ticket.customerName.toLowerCase().contains(q) ||
          ticket.customerEmail.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  int countWhere(bool Function(Ticket) test) => tickets.where(test).length;

  Ticket? byId(String id) {
    for (final ticket in tickets) {
      if (ticket.id == id) return ticket;
    }
    return null;
  }

  TicketListState copyWith({
    List<Ticket>? tickets,
    String? query,
    TicketStatus? statusFilter,
    TicketPriority? priorityFilter,
    bool clearStatusFilter = false,
    bool clearPriorityFilter = false,
  }) {
    return TicketListState(
      tickets: tickets ?? this.tickets,
      query: query ?? this.query,
      statusFilter:
          clearStatusFilter ? null : statusFilter ?? this.statusFilter,
      priorityFilter:
          clearPriorityFilter ? null : priorityFilter ?? this.priorityFilter,
    );
  }

  @override
  List<Object?> get props =>
      [tickets, query, statusFilter, priorityFilter];
}

class TicketListCubit extends Cubit<TicketListState> {
  TicketListCubit({List<Ticket>? seed})
      : super(
          TicketListState(
            tickets: seed ?? MockTickets.createCatalog(),
          ),
        );

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setStatusFilter(TicketStatus? status) {
    if (status == null) {
      emit(state.copyWith(clearStatusFilter: true));
      return;
    }
    emit(state.copyWith(statusFilter: status));
  }

  void setPriorityFilter(TicketPriority? priority) {
    if (priority == null) {
      emit(state.copyWith(clearPriorityFilter: true));
      return;
    }
    emit(state.copyWith(priorityFilter: priority));
  }

  void applyRouteFilter(String segment) {
    switch (segment) {
      case 'open':
        setStatusFilter(TicketStatus.open);
      case 'pending':
        setStatusFilter(TicketStatus.pending);
      case 'resolved':
        setStatusFilter(TicketStatus.resolved);
      case 'all':
      default:
        setStatusFilter(null);
    }
  }

  void updateStatus(String ticketId, TicketStatus status) {
    _replace(
      ticketId,
      (ticket) => ticket.copyWith(status: status, updatedAt: DateTime.now()),
    );
  }

  void assign(String ticketId, String? assigneeName) {
    _replace(
      ticketId,
      (ticket) => ticket.copyWith(
        assigneeName: assigneeName ?? '',
        updatedAt: DateTime.now(),
      ),
    );
  }

  void addReply({
    required String ticketId,
    required String body,
    required String agentName,
  }) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    _replace(ticketId, (ticket) {
      final message = TicketMessage(
        id: 'm-${DateTime.now().microsecondsSinceEpoch}',
        authorName: agentName,
        body: trimmed,
        createdAt: DateTime.now(),
        isAgent: true,
      );
      return ticket.copyWith(
        messages: [...ticket.messages, message],
        updatedAt: DateTime.now(),
        status: ticket.status == TicketStatus.open
            ? TicketStatus.inProgress
            : ticket.status,
      );
    });
  }

  void _replace(String ticketId, Ticket Function(Ticket) transform) {
    final next = [
      for (final ticket in state.tickets)
        if (ticket.id == ticketId) transform(ticket) else ticket,
    ];
    emit(state.copyWith(tickets: next));
  }
}
