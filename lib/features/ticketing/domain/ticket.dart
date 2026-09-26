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

/// Ledger entry for the ticket activity timeline.
class TicketEvent extends Equatable {
  const TicketEvent({
    required this.id,
    required this.action,
    required this.at,
    this.detail,
    this.actorName,
  });

  final String id;
  final String action;
  final String? detail;
  final DateTime at;
  final String? actorName;

  @override
  List<Object?> get props => [id, action, detail, at, actorName];
}

class TicketAttachment extends Equatable {
  const TicketAttachment({
    required this.id,
    required this.name,
    required this.sizeLabel,
    required this.kind,
  });

  final String id;
  final String name;
  final String sizeLabel;

  /// `image` | `pdf` | `file`
  final String kind;

  @override
  List<Object?> get props => [id, name, sizeLabel, kind];
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
    this.events = const [],
    this.attachments = const [],
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
  final List<TicketEvent> events;
  final List<TicketAttachment> attachments;

  Ticket copyWith({
    TicketStatus? status,
    TicketPriority? priority,
    String? assigneeName,
    DateTime? updatedAt,
    List<TicketMessage>? messages,
    List<TicketEvent>? events,
    List<TicketAttachment>? attachments,
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
      events: events ?? this.events,
      attachments: attachments ?? this.attachments,
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
        events,
        attachments,
      ];
}
