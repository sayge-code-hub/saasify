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
    this.priorityQueue = false,
    this.selectedIds = const {},
  });

  final List<Ticket> tickets;
  final String query;
  final TicketStatus? statusFilter;
  final TicketPriority? priorityFilter;

  /// When true, show urgent + high tickets (Priority Tickets view).
  final bool priorityQueue;
  final Set<String> selectedIds;

  List<Ticket> get visible {
    final q = query.trim().toLowerCase();
    return tickets.where((ticket) {
      if (statusFilter != null && ticket.status != statusFilter) {
        return false;
      }
      if (priorityQueue) {
        if (ticket.priority != TicketPriority.urgent &&
            ticket.priority != TicketPriority.high) {
          return false;
        }
      } else if (priorityFilter != null &&
          ticket.priority != priorityFilter) {
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

  bool get hasSelection => selectedIds.isNotEmpty;

  bool isSelected(String id) => selectedIds.contains(id);

  bool get allVisibleSelected {
    final ids = visible.map((t) => t.id).toList();
    if (ids.isEmpty) return false;
    return ids.every(selectedIds.contains);
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
    bool? priorityQueue,
    Set<String>? selectedIds,
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
      priorityQueue: priorityQueue ?? this.priorityQueue,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [
        tickets,
        query,
        statusFilter,
        priorityFilter,
        priorityQueue,
        selectedIds,
      ];
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
      emit(state.copyWith(clearStatusFilter: true, priorityQueue: false));
      return;
    }
    emit(
      state.copyWith(
        statusFilter: status,
        priorityQueue: false,
      ),
    );
  }

  void setPriorityFilter(TicketPriority? priority) {
    if (priority == null) {
      emit(state.copyWith(clearPriorityFilter: true, priorityQueue: false));
      return;
    }
    emit(
      state.copyWith(
        priorityFilter: priority,
        priorityQueue: false,
      ),
    );
  }

  void applyRouteFilter(String segment) {
    switch (segment) {
      case 'open':
        emit(
          state.copyWith(
            statusFilter: TicketStatus.open,
            clearPriorityFilter: true,
            priorityQueue: false,
            selectedIds: const {},
          ),
        );
      case 'pending':
        emit(
          state.copyWith(
            statusFilter: TicketStatus.pending,
            clearPriorityFilter: true,
            priorityQueue: false,
            selectedIds: const {},
          ),
        );
      case 'resolved':
        emit(
          state.copyWith(
            statusFilter: TicketStatus.resolved,
            clearPriorityFilter: true,
            priorityQueue: false,
            selectedIds: const {},
          ),
        );
      case 'priority':
        emit(
          state.copyWith(
            clearStatusFilter: true,
            clearPriorityFilter: true,
            priorityQueue: true,
            selectedIds: const {},
          ),
        );
      case 'all':
      default:
        emit(
          state.copyWith(
            clearStatusFilter: true,
            clearPriorityFilter: true,
            priorityQueue: false,
            selectedIds: const {},
          ),
        );
    }
  }

  void toggleSelected(String id) {
    final next = {...state.selectedIds};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    emit(state.copyWith(selectedIds: next));
  }

  void selectAllVisible() {
    emit(
      state.copyWith(
        selectedIds: state.visible.map((t) => t.id).toSet(),
      ),
    );
  }

  void clearSelection() {
    if (state.selectedIds.isEmpty) return;
    emit(state.copyWith(selectedIds: const {}));
  }

  void deleteSelected() {
    if (state.selectedIds.isEmpty) return;
    final remaining = state.tickets
        .where((t) => !state.selectedIds.contains(t.id))
        .toList();
    emit(state.copyWith(tickets: remaining, selectedIds: const {}));
  }

  void deleteTickets(Iterable<String> ids) {
    final idSet = ids.toSet();
    if (idSet.isEmpty) return;
    final remaining =
        state.tickets.where((t) => !idSet.contains(t.id)).toList();
    final selected =
        state.selectedIds.where((id) => !idSet.contains(id)).toSet();
    emit(state.copyWith(tickets: remaining, selectedIds: selected));
  }

  /// Creates a new open ticket and returns its id.
  String createTicket({
    required String subject,
    required String description,
    required String customerName,
    required String customerEmail,
    TicketPriority priority = TicketPriority.medium,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    var maxId = 0;
    for (final ticket in state.tickets) {
      final n = int.tryParse(ticket.id.replaceFirst('TCK-', '')) ?? 0;
      if (n > maxId) maxId = n;
    }
    final id = 'TCK-${maxId + 1}';
    final ticket = Ticket(
      id: id,
      subject: subject.trim(),
      description: description.trim(),
      status: TicketStatus.open,
      priority: priority,
      customerName: customerName.trim(),
      customerEmail: customerEmail.trim(),
      createdAt: now,
      updatedAt: now,
      tags: tags,
      messages: [
        TicketMessage(
          id: 'm-${now.microsecondsSinceEpoch}',
          authorName: customerName.trim(),
          body: description.trim(),
          createdAt: now,
          isAgent: false,
        ),
      ],
    );
    emit(state.copyWith(tickets: [ticket, ...state.tickets]));
    return id;
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
