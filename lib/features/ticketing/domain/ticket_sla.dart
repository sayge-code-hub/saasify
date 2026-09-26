import 'package:equatable/equatable.dart';

import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/domain/ticket_config.dart';

/// Lifecycle of one SLA clock (first response or resolution).
enum SlaClockStatus {
  /// Still open and comfortably within the target.
  onTrack,

  /// Still open, but little time remains (see [TicketConfig.atRiskRatio]).
  atRisk,

  /// Deadline passed while the clock was still open.
  breached,

  /// Completed before the deadline.
  met,

  /// Completed after the deadline.
  metLate,
}

extension SlaClockStatusX on SlaClockStatus {
  String get label => switch (this) {
        SlaClockStatus.onTrack => 'On track',
        SlaClockStatus.atRisk => 'At risk',
        SlaClockStatus.breached => 'Breached',
        SlaClockStatus.met => 'Met',
        SlaClockStatus.metLate => 'Met late',
      };

  bool get isOpen =>
      this == SlaClockStatus.onTrack || this == SlaClockStatus.atRisk;

  bool get isBreached =>
      this == SlaClockStatus.breached || this == SlaClockStatus.metLate;
}

class SlaClock extends Equatable {
  const SlaClock({
    required this.label,
    required this.target,
    required this.dueAt,
    required this.status,
    required this.completedAt,
  });

  final String label;
  final Duration target;
  final DateTime dueAt;
  final SlaClockStatus status;
  final DateTime? completedAt;

  @override
  List<Object?> get props => [label, target, dueAt, status, completedAt];
}

/// Computed SLA snapshot for a ticket at [now].
class TicketSlaSnapshot extends Equatable {
  const TicketSlaSnapshot({
    required this.firstResponse,
    required this.resolution,
  });

  final SlaClock firstResponse;
  final SlaClock resolution;

  bool get anyBreached =>
      firstResponse.status.isBreached || resolution.status.isBreached;

  bool get anyAtRisk =>
      firstResponse.status == SlaClockStatus.atRisk ||
      resolution.status == SlaClockStatus.atRisk;

  @override
  List<Object?> get props => [firstResponse, resolution];
}

/// Pure SLA calculator — no Flutter dependencies.
abstract final class TicketSla {
  /// First agent reply time, or an explicit stamp on the ticket.
  static DateTime? firstRespondedAt(Ticket ticket) {
    if (ticket.firstRespondedAt != null) return ticket.firstRespondedAt;
    for (final message in ticket.messages) {
      if (message.isAgent) return message.createdAt;
    }
    return null;
  }

  /// Resolution time when status is resolved/closed.
  static DateTime? resolvedAt(Ticket ticket) {
    if (ticket.status != TicketStatus.resolved &&
        ticket.status != TicketStatus.closed) {
      return null;
    }
    if (ticket.resolvedAt != null) return ticket.resolvedAt;
    for (final event in ticket.events.reversed) {
      if (event.action == 'Status changed' &&
          (event.detail?.contains('Resolved') == true ||
              event.detail?.contains('Closed') == true)) {
        return event.at;
      }
    }
    return ticket.updatedAt;
  }

  static TicketSlaSnapshot evaluate({
    required Ticket ticket,
    required TicketConfig config,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final target = config.slaFor(ticket.priority);
    final responded = firstRespondedAt(ticket);
    final resolved = resolvedAt(ticket);

    return TicketSlaSnapshot(
      firstResponse: _clock(
        label: 'First response',
        createdAt: ticket.createdAt,
        target: target.firstResponse,
        completedAt: responded,
        now: at,
        atRiskRatio: config.atRiskRatio,
      ),
      resolution: _clock(
        label: 'Resolution',
        createdAt: ticket.createdAt,
        target: target.resolution,
        completedAt: resolved,
        now: at,
        atRiskRatio: config.atRiskRatio,
      ),
    );
  }

  static SlaClock _clock({
    required String label,
    required DateTime createdAt,
    required Duration target,
    required DateTime? completedAt,
    required DateTime now,
    required double atRiskRatio,
  }) {
    final dueAt = createdAt.add(target);
    final SlaClockStatus status;
    if (completedAt != null) {
      status = !completedAt.isAfter(dueAt)
          ? SlaClockStatus.met
          : SlaClockStatus.metLate;
    } else if (now.isAfter(dueAt)) {
      status = SlaClockStatus.breached;
    } else {
      final remaining = dueAt.difference(now);
      final ratioLeft = target.inMicroseconds == 0
          ? 0.0
          : remaining.inMicroseconds / target.inMicroseconds;
      status = ratioLeft <= atRiskRatio
          ? SlaClockStatus.atRisk
          : SlaClockStatus.onTrack;
    }

    return SlaClock(
      label: label,
      target: target,
      dueAt: dueAt,
      status: status,
      completedAt: completedAt,
    );
  }

  static String formatDuration(Duration duration) {
    final abs = duration.abs();
    if (abs.inDays >= 1) {
      final days = abs.inDays;
      final hours = abs.inHours.remainder(24);
      if (hours == 0) return '${days}d';
      return '${days}d ${hours}h';
    }
    if (abs.inHours >= 1) {
      final hours = abs.inHours;
      final minutes = abs.inMinutes.remainder(60);
      if (minutes == 0) return '${hours}h';
      return '${hours}h ${minutes}m';
    }
    final minutes = abs.inMinutes;
    if (minutes <= 0) return '${abs.inSeconds}s';
    return '${minutes}m';
  }
}
