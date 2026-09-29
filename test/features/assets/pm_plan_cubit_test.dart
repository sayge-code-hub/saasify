import 'package:flutter_test/flutter_test.dart';
import 'package:saasify/features/assets/domain/pm_plan.dart';
import 'package:saasify/features/assets/presentation/bloc/pm_plan_cubit.dart';

void main() {
  group('PmPlanCubit', () {
    test('filters by asset and completes a plan', () {
      final cubit = PmPlanCubit();
      addTearDown(cubit.close);

      cubit.setAssetFilter('AST-1006');
      expect(cubit.state.visible.every((p) => p.assetId == 'AST-1006'), isTrue);

      final id = cubit.state.visible.first.id;
      final before = cubit.state.byId(id)!;
      cubit.completePlan(id, completedAt: DateTime(2026, 10, 1));
      final after = cubit.state.byId(id)!;

      expect(after.lastCompleted, DateTime(2026, 10, 1));
      expect(
        after.nextDueDate,
        before.frequency.nextDueAfter(DateTime(2026, 10, 1)),
      );
      expect(after.checklist.every((c) => !c.done), isTrue);
      expect(after.status, PmPlanStatus.scheduled);
    });

    test('toggles checklist items', () {
      final cubit = PmPlanCubit();
      addTearDown(cubit.close);
      cubit.toggleChecklistItem('PM-1001', 'c1');
      final item =
          cubit.state.byId('PM-1001')!.checklist.firstWhere((c) => c.id == 'c1');
      expect(item.done, isTrue);
    });
  });
}
