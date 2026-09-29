import 'package:equatable/equatable.dart';

enum PmFrequency {
  daily,
  weekly,
  monthly,
  quarterly,
  halfYearly,
  yearly,
  meterBased,
}

extension PmFrequencyX on PmFrequency {
  String get label => switch (this) {
        PmFrequency.daily => 'Daily',
        PmFrequency.weekly => 'Weekly',
        PmFrequency.monthly => 'Monthly',
        PmFrequency.quarterly => 'Quarterly',
        PmFrequency.halfYearly => 'Half-yearly',
        PmFrequency.yearly => 'Yearly',
        PmFrequency.meterBased => 'Meter-based',
      };

  /// Advances [from] by one cycle. Meter-based leaves the date unchanged
  /// (due is driven by readings later).
  DateTime nextDueAfter(DateTime from) {
    return switch (this) {
      PmFrequency.daily => from.add(const Duration(days: 1)),
      PmFrequency.weekly => from.add(const Duration(days: 7)),
      PmFrequency.monthly => DateTime(from.year, from.month + 1, from.day),
      PmFrequency.quarterly => DateTime(from.year, from.month + 3, from.day),
      PmFrequency.halfYearly => DateTime(from.year, from.month + 6, from.day),
      PmFrequency.yearly => DateTime(from.year + 1, from.month, from.day),
      PmFrequency.meterBased => from,
    };
  }
}

enum PmPriority { low, medium, high, urgent }

extension PmPriorityX on PmPriority {
  String get label => switch (this) {
        PmPriority.low => 'Low',
        PmPriority.medium => 'Medium',
        PmPriority.high => 'High',
        PmPriority.urgent => 'Urgent',
      };
}

enum PmPlanStatus { scheduled, dueSoon, overdue, completed, paused }

extension PmPlanStatusX on PmPlanStatus {
  String get label => switch (this) {
        PmPlanStatus.scheduled => 'Scheduled',
        PmPlanStatus.dueSoon => 'Due soon',
        PmPlanStatus.overdue => 'Overdue',
        PmPlanStatus.completed => 'Completed',
        PmPlanStatus.paused => 'Paused',
      };
}

class PmChecklistItem extends Equatable {
  const PmChecklistItem({
    required this.id,
    required this.label,
    this.done = false,
  });

  final String id;
  final String label;
  final bool done;

  PmChecklistItem copyWith({String? id, String? label, bool? done}) {
    return PmChecklistItem(
      id: id ?? this.id,
      label: label ?? this.label,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => [id, label, done];
}

class PmPlan extends Equatable {
  const PmPlan({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.maintenanceType,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    required this.assignedTeam,
    required this.assignedTechnician,
    required this.priority,
    required this.checklist,
    required this.estimatedDuration,
    required this.instructions,
    required this.status,
    this.lastCompleted,
  });

  final String id;
  final String assetId;
  final String assetName;
  final String maintenanceType;
  final PmFrequency frequency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final String assignedTeam;
  final String assignedTechnician;
  final PmPriority priority;
  final List<PmChecklistItem> checklist;
  final Duration estimatedDuration;
  final String instructions;
  final PmPlanStatus status;
  final DateTime? lastCompleted;

  /// Recomputes dueSoon / overdue from [now] when not paused/completed.
  PmPlanStatus statusAt(DateTime now) {
    if (status == PmPlanStatus.paused || status == PmPlanStatus.completed) {
      return status;
    }
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
    );
    if (due.isBefore(today)) return PmPlanStatus.overdue;
    if (!due.isAfter(today.add(const Duration(days: 7)))) {
      return PmPlanStatus.dueSoon;
    }
    return PmPlanStatus.scheduled;
  }

  PmPlan copyWith({
    String? id,
    String? assetId,
    String? assetName,
    String? maintenanceType,
    PmFrequency? frequency,
    DateTime? startDate,
    DateTime? nextDueDate,
    String? assignedTeam,
    String? assignedTechnician,
    PmPriority? priority,
    List<PmChecklistItem>? checklist,
    Duration? estimatedDuration,
    String? instructions,
    PmPlanStatus? status,
    DateTime? lastCompleted,
    bool clearLastCompleted = false,
  }) {
    return PmPlan(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      assignedTechnician: assignedTechnician ?? this.assignedTechnician,
      priority: priority ?? this.priority,
      checklist: checklist ?? this.checklist,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      instructions: instructions ?? this.instructions,
      status: status ?? this.status,
      lastCompleted:
          clearLastCompleted ? null : lastCompleted ?? this.lastCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        assetId,
        assetName,
        maintenanceType,
        frequency,
        startDate,
        nextDueDate,
        assignedTeam,
        assignedTechnician,
        priority,
        checklist,
        estimatedDuration,
        instructions,
        status,
        lastCompleted,
      ];
}
