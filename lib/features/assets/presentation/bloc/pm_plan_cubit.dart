import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/assets/data/mock_pm_plans.dart';
import 'package:saasify/features/assets/domain/pm_plan.dart';

class PmPlanState extends Equatable {
  const PmPlanState({
    required this.plans,
    this.query = '',
    this.assetFilterId,
  });

  final List<PmPlan> plans;
  final String query;
  final String? assetFilterId;

  List<PmPlan> get visible {
    final q = query.trim().toLowerCase();
    final now = DateTime.now();
    final list = plans.where((plan) {
      if (assetFilterId != null && plan.assetId != assetFilterId) {
        return false;
      }
      if (q.isEmpty) return true;
      return plan.id.toLowerCase().contains(q) ||
          plan.assetName.toLowerCase().contains(q) ||
          plan.maintenanceType.toLowerCase().contains(q) ||
          plan.assignedTeam.toLowerCase().contains(q) ||
          plan.assignedTechnician.toLowerCase().contains(q) ||
          plan.frequency.label.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        final sa = a.statusAt(now);
        final sb = b.statusAt(now);
        final rank = _statusRank(sa).compareTo(_statusRank(sb));
        if (rank != 0) return rank;
        return a.nextDueDate.compareTo(b.nextDueDate);
      });
    return list;
  }

  static int _statusRank(PmPlanStatus status) => switch (status) {
        PmPlanStatus.overdue => 0,
        PmPlanStatus.dueSoon => 1,
        PmPlanStatus.scheduled => 2,
        PmPlanStatus.paused => 3,
        PmPlanStatus.completed => 4,
      };

  PmPlan? byId(String id) {
    for (final plan in plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  List<PmPlan> forAsset(String assetId) =>
      plans.where((p) => p.assetId == assetId).toList();

  PmPlanState copyWith({
    List<PmPlan>? plans,
    String? query,
    String? assetFilterId,
    bool clearAssetFilter = false,
  }) {
    return PmPlanState(
      plans: plans ?? this.plans,
      query: query ?? this.query,
      assetFilterId:
          clearAssetFilter ? null : assetFilterId ?? this.assetFilterId,
    );
  }

  @override
  List<Object?> get props => [plans, query, assetFilterId];
}

class PmPlanCubit extends Cubit<PmPlanState> {
  PmPlanCubit({List<PmPlan>? seed})
      : super(PmPlanState(plans: seed ?? MockPmPlans.createCatalog()));

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setAssetFilter(String? assetId) {
    if (assetId == null) {
      emit(state.copyWith(clearAssetFilter: true));
      return;
    }
    emit(state.copyWith(assetFilterId: assetId));
  }

  String createPlan(PmPlan draft) {
    final id = _nextId();
    final plan = draft.copyWith(id: id);
    emit(state.copyWith(plans: [plan, ...state.plans]));
    return id;
  }

  void updatePlan(PmPlan updated) {
    emit(
      state.copyWith(
        plans: [
          for (final plan in state.plans)
            if (plan.id == updated.id) updated else plan,
        ],
      ),
    );
  }

  void deletePlan(String id) {
    emit(
      state.copyWith(
        plans: [for (final plan in state.plans) if (plan.id != id) plan],
      ),
    );
  }

  void toggleChecklistItem(String planId, String itemId) {
    final plan = state.byId(planId);
    if (plan == null) return;
    updatePlan(
      plan.copyWith(
        checklist: [
          for (final item in plan.checklist)
            if (item.id == itemId) item.copyWith(done: !item.done) else item,
        ],
      ),
    );
  }

  /// Marks PM complete: resets checklist, advances next due, sets last completed.
  void completePlan(String planId, {DateTime? completedAt}) {
    final plan = state.byId(planId);
    if (plan == null) return;
    final when = completedAt ?? DateTime.now();
    final next = plan.frequency.nextDueAfter(when);
    updatePlan(
      plan.copyWith(
        lastCompleted: when,
        nextDueDate: next,
        status: PmPlanStatus.scheduled,
        checklist: [
          for (final item in plan.checklist) item.copyWith(done: false),
        ],
      ),
    );
  }

  String _nextId() {
    var max = 1000;
    for (final plan in state.plans) {
      final raw = plan.id.replaceFirst('PM-', '');
      final value = int.tryParse(raw);
      if (value != null && value > max) max = value;
    }
    return 'PM-${max + 1}';
  }
}
