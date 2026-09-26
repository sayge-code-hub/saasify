import 'package:equatable/equatable.dart';

import 'package:saasify/features/ticketing/data/mock_tickets.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';

/// Per-priority SLA targets. Clocks start at ticket creation.
///
/// - [firstResponse]: max time until the first agent reply
/// - [resolution]: max time until the ticket is resolved or closed
class SlaTarget extends Equatable {
  const SlaTarget({
    required this.firstResponse,
    required this.resolution,
  });

  final Duration firstResponse;
  final Duration resolution;

  SlaTarget copyWith({
    Duration? firstResponse,
    Duration? resolution,
  }) {
    return SlaTarget(
      firstResponse: firstResponse ?? this.firstResponse,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  List<Object?> get props => [firstResponse, resolution];
}

/// Workspace ticketing configuration (dropdown options + SLA policy).
class TicketConfig extends Equatable {
  const TicketConfig({
    required this.applications,
    required this.distributionLists,
    required this.assignees,
    required this.bugOptions,
    required this.enabledPriorities,
    required this.slaByPriority,
    this.atRiskRatio = 0.2,
  });

  final List<String> applications;
  final List<String> distributionLists;
  final List<String> assignees;

  /// Values shown in the Bug dropdown (typically Yes / No).
  final List<String> bugOptions;

  /// Priorities offered on the create form, in display order.
  final List<TicketPriority> enabledPriorities;

  final Map<TicketPriority, SlaTarget> slaByPriority;

  /// Fraction of remaining SLA time at which status becomes "At risk".
  final double atRiskRatio;

  factory TicketConfig.defaults() {
    return TicketConfig(
      applications: List<String>.from(MockTickets.applications),
      distributionLists: List<String>.from(MockTickets.distributionLists),
      assignees: List<String>.from(MockTickets.assignees),
      bugOptions: const ['No', 'Yes'],
      enabledPriorities: List<TicketPriority>.from(TicketPriority.values),
      slaByPriority: const {
        TicketPriority.urgent: SlaTarget(
          firstResponse: Duration(hours: 1),
          resolution: Duration(hours: 4),
        ),
        TicketPriority.high: SlaTarget(
          firstResponse: Duration(hours: 4),
          resolution: Duration(hours: 24),
        ),
        TicketPriority.medium: SlaTarget(
          firstResponse: Duration(hours: 8),
          resolution: Duration(hours: 72),
        ),
        TicketPriority.low: SlaTarget(
          firstResponse: Duration(hours: 24),
          resolution: Duration(hours: 120),
        ),
      },
    );
  }

  SlaTarget slaFor(TicketPriority priority) {
    return slaByPriority[priority] ??
        const SlaTarget(
          firstResponse: Duration(hours: 8),
          resolution: Duration(hours: 72),
        );
  }

  TicketConfig copyWith({
    List<String>? applications,
    List<String>? distributionLists,
    List<String>? assignees,
    List<String>? bugOptions,
    List<TicketPriority>? enabledPriorities,
    Map<TicketPriority, SlaTarget>? slaByPriority,
    double? atRiskRatio,
  }) {
    return TicketConfig(
      applications: applications ?? this.applications,
      distributionLists: distributionLists ?? this.distributionLists,
      assignees: assignees ?? this.assignees,
      bugOptions: bugOptions ?? this.bugOptions,
      enabledPriorities: enabledPriorities ?? this.enabledPriorities,
      slaByPriority: slaByPriority ?? this.slaByPriority,
      atRiskRatio: atRiskRatio ?? this.atRiskRatio,
    );
  }

  @override
  List<Object?> get props => [
        applications,
        distributionLists,
        assignees,
        bugOptions,
        enabledPriorities,
        slaByPriority,
        atRiskRatio,
      ];
}
