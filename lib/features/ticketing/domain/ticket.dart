import 'package:equatable/equatable.dart';

enum TicketStatus { open, inProgress, pending, resolved, closed }

enum TicketPriority { low, medium, high, urgent }

extension TicketStatusX on TicketStatus {
  String get label => switch (this) {
        TicketStatus.open => 'Open',
        TicketStatus.inProgress => 'In progress',
        TicketStatus.pending => 'Pending',
        TicketStatus.resolved => 'Resolved',
        TicketStatus.closed => 'Closed',
      };

  /// Next sensible workflow step for admin actions.
  TicketStatus? get next => switch (this) {
        TicketStatus.open => TicketStatus.inProgress,
        TicketStatus.inProgress => TicketStatus.pending,
        TicketStatus.pending => TicketStatus.resolved,
        TicketStatus.resolved => TicketStatus.closed,
        TicketStatus.closed => null,
      };
}

extension TicketPriorityX on TicketPriority {
  String get label => switch (this) {
        TicketPriority.low => 'Low',
        TicketPriority.medium => 'Medium',
        TicketPriority.high => 'High',
        TicketPriority.urgent => 'Urgent',
      };
}

class TicketMessage extends Equatable {
  const TicketMessage({
    required this.id,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.isAgent,
  });

  final String id;
  final String authorName;
  final String body;
  final DateTime createdAt;
  final bool isAgent;

  @override
  List<Object?> get props => [id, authorName, body, createdAt, isAgent];
}

class Ticket extends Equatable {
  const Ticket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.customerName,
    required this.customerEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.assigneeName,
    this.tags = const [],
  });

  final String id;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final String customerName;
  final String customerEmail;
  final String? assigneeName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketMessage> messages;
  final List<String> tags;

  Ticket copyWith({
    TicketStatus? status,
    TicketPriority? priority,
    String? assigneeName,
    DateTime? updatedAt,
    List<TicketMessage>? messages,
  }) {
    return Ticket(
      id: id,
      subject: subject,
      description: description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      customerName: customerName,
      customerEmail: customerEmail,
      assigneeName: assigneeName ?? this.assigneeName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      tags: tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subject,
        description,
        status,
        priority,
        customerName,
        customerEmail,
        assigneeName,
        createdAt,
        updatedAt,
        messages,
        tags,
      ];
}
