import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/domain/ticket_config.dart';

class TicketConfigCubit extends Cubit<TicketConfig> {
  TicketConfigCubit({TicketConfig? initial})
      : super(initial ?? TicketConfig.defaults());

  void setApplications(List<String> values) {
    emit(state.copyWith(applications: _cleanList(values)));
  }

  void setDistributionLists(List<String> values) {
    emit(state.copyWith(distributionLists: _cleanList(values)));
  }

  void setAssignees(List<String> values) {
    emit(state.copyWith(assignees: _cleanList(values)));
  }

  void setBugOptions(List<String> values) {
    final cleaned = _cleanList(values);
    if (cleaned.isEmpty) return;
    emit(state.copyWith(bugOptions: cleaned));
  }

  void setEnabledPriorities(List<TicketPriority> values) {
    if (values.isEmpty) return;
    emit(state.copyWith(enabledPriorities: List<TicketPriority>.from(values)));
  }

  void setSlaTarget(TicketPriority priority, SlaTarget target) {
    final next = Map<TicketPriority, SlaTarget>.from(state.slaByPriority);
    next[priority] = target;
    emit(state.copyWith(slaByPriority: next));
  }

  void setFirstResponseHours(TicketPriority priority, double hours) {
    final current = state.slaFor(priority);
    setSlaTarget(
      priority,
      current.copyWith(firstResponse: _hoursToDuration(hours)),
    );
  }

  void setResolutionHours(TicketPriority priority, double hours) {
    final current = state.slaFor(priority);
    setSlaTarget(
      priority,
      current.copyWith(resolution: _hoursToDuration(hours)),
    );
  }

  void addListItem(TicketConfigListKind kind, String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    switch (kind) {
      case TicketConfigListKind.applications:
        if (state.applications.contains(value)) return;
        setApplications([...state.applications, value]);
      case TicketConfigListKind.distributionLists:
        if (state.distributionLists.contains(value)) return;
        setDistributionLists([...state.distributionLists, value]);
      case TicketConfigListKind.assignees:
        if (state.assignees.contains(value)) return;
        setAssignees([...state.assignees, value]);
      case TicketConfigListKind.bugOptions:
        if (state.bugOptions.contains(value)) return;
        setBugOptions([...state.bugOptions, value]);
    }
  }

  void removeListItem(TicketConfigListKind kind, String value) {
    switch (kind) {
      case TicketConfigListKind.applications:
        if (state.applications.length <= 1) return;
        setApplications(
          state.applications.where((e) => e != value).toList(),
        );
      case TicketConfigListKind.distributionLists:
        if (state.distributionLists.length <= 1) return;
        setDistributionLists(
          state.distributionLists.where((e) => e != value).toList(),
        );
      case TicketConfigListKind.assignees:
        setAssignees(state.assignees.where((e) => e != value).toList());
      case TicketConfigListKind.bugOptions:
        if (state.bugOptions.length <= 1) return;
        setBugOptions(state.bugOptions.where((e) => e != value).toList());
    }
  }

  void togglePriority(TicketPriority priority, bool enabled) {
    final current = [...state.enabledPriorities];
    if (enabled) {
      if (!current.contains(priority)) {
        // Keep enum order.
        final next = [
          for (final p in TicketPriority.values)
            if (p == priority || current.contains(p)) p,
        ];
        setEnabledPriorities(next);
      }
    } else {
      if (current.length <= 1) return;
      setEnabledPriorities(current.where((p) => p != priority).toList());
    }
  }

  void resetDefaults() => emit(TicketConfig.defaults());

  static List<String> _cleanList(List<String> values) {
    final seen = <String>{};
    final out = <String>[];
    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty || seen.contains(value)) continue;
      seen.add(value);
      out.add(value);
    }
    return out;
  }

  static Duration _hoursToDuration(double hours) {
    final clamped = hours.isNaN || hours <= 0 ? 0.25 : hours;
    final minutes = (clamped * 60).round().clamp(1, 60 * 24 * 30);
    return Duration(minutes: minutes);
  }
}

enum TicketConfigListKind {
  applications,
  distributionLists,
  assignees,
  bugOptions,
}
