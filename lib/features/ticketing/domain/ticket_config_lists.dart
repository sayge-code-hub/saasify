import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';

/// Display metadata for configurable option lists.
extension TicketConfigListKindX on TicketConfigListKind {
  String get pathSegment => switch (this) {
        TicketConfigListKind.applications => 'applications',
        TicketConfigListKind.distributionLists => 'distribution-lists',
        TicketConfigListKind.assignees => 'assignees',
        TicketConfigListKind.bugOptions => 'bug-options',
      };

  String get title => switch (this) {
        TicketConfigListKind.applications => 'Applications',
        TicketConfigListKind.distributionLists => 'Distribution lists',
        TicketConfigListKind.assignees => 'Assignees',
        TicketConfigListKind.bugOptions => 'Bug options',
      };

  String get singular => switch (this) {
        TicketConfigListKind.applications => 'application',
        TicketConfigListKind.distributionLists => 'distribution list',
        TicketConfigListKind.assignees => 'assignee',
        TicketConfigListKind.bugOptions => 'bug option',
      };

  String get subtitle => switch (this) {
        TicketConfigListKind.applications =>
          'Shown in the Application dropdown on Add Ticket.',
        TicketConfigListKind.distributionLists =>
          'Shown in the Distribution List dropdown on Add Ticket.',
        TicketConfigListKind.assignees =>
          'Agents available when assigning a ticket on the detail page.',
        TicketConfigListKind.bugOptions =>
          'Shown in the Bug dropdown on Add Ticket.',
      };

  String get addLabel => 'Add ${singular[0].toUpperCase()}${singular.substring(1)}';

  bool get allowEmpty => this == TicketConfigListKind.assignees;

  static TicketConfigListKind? tryParse(String segment) {
    for (final kind in TicketConfigListKind.values) {
      if (kind.pathSegment == segment) return kind;
    }
    return null;
  }
}
