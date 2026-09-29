import 'package:saasify/features/assets/domain/pm_plan.dart';

/// Seed PM plans for Asset Management MVP (linked to mock assets).
abstract final class MockPmPlans {
  static const teams = <String>[
    'Mechanical Team',
    'Electrical Team',
    'Instrumentation',
    'Operations',
  ];

  static const technicians = <String>[
    'Alex Rivera',
    'Jamie Fox',
    'Sam Okonkwo',
    'Priya Shah',
    'Unassigned',
  ];

  static const maintenanceTypes = <String>[
    'Inspection',
    'Lubrication',
    'Calibration',
    'Overhaul',
    'Safety check',
  ];

  static List<PmPlan> createCatalog() {
    return [
      PmPlan(
        id: 'PM-1001',
        assetId: 'AST-1006',
        assetName: 'Charge Pump A',
        maintenanceType: 'Inspection',
        frequency: PmFrequency.monthly,
        startDate: DateTime(2026, 1, 15),
        nextDueDate: DateTime(2026, 10, 15),
        assignedTeam: 'Mechanical Team',
        assignedTechnician: 'Alex Rivera',
        priority: PmPriority.high,
        checklist: const [
          PmChecklistItem(id: 'c1', label: 'Check vibration'),
          PmChecklistItem(id: 'c2', label: 'Check oil level'),
          PmChecklistItem(id: 'c3', label: 'Inspect coupling'),
          PmChecklistItem(id: 'c4', label: 'Check leakage'),
        ],
        estimatedDuration: const Duration(hours: 2),
        instructions:
            'Isolate pump before inspection. Record vibration readings '
            'at drive and non-drive ends. Top up oil only with approved grade.',
        status: PmPlanStatus.dueSoon,
        lastCompleted: DateTime(2026, 9, 15),
      ),
      PmPlan(
        id: 'PM-1002',
        assetId: 'AST-1001',
        assetName: 'AIT-1000',
        maintenanceType: 'Calibration',
        frequency: PmFrequency.quarterly,
        startDate: DateTime(2026, 3, 1),
        nextDueDate: DateTime(2026, 11, 1),
        assignedTeam: 'Instrumentation',
        assignedTechnician: 'Priya Shah',
        priority: PmPriority.medium,
        checklist: const [
          PmChecklistItem(id: 'c1', label: 'Verify zero / span'),
          PmChecklistItem(id: 'c2', label: 'Clean sensor window'),
          PmChecklistItem(id: 'c3', label: 'Update calibration certificate'),
        ],
        estimatedDuration: const Duration(hours: 1, minutes: 30),
        instructions:
            'Use certified gas for span check. Tag out if reading drifts >2%.',
        status: PmPlanStatus.scheduled,
        lastCompleted: DateTime(2026, 8, 1),
      ),
      PmPlan(
        id: 'PM-1003',
        assetId: 'AST-1007',
        assetName: 'ESD Valve 14',
        maintenanceType: 'Safety check',
        frequency: PmFrequency.weekly,
        startDate: DateTime(2026, 9, 1),
        nextDueDate: DateTime(2026, 9, 22),
        assignedTeam: 'Operations',
        assignedTechnician: 'Jamie Fox',
        priority: PmPriority.urgent,
        checklist: const [
          PmChecklistItem(id: 'c1', label: 'Stroke test'),
          PmChecklistItem(id: 'c2', label: 'Confirm limit switches'),
          PmChecklistItem(id: 'c3', label: 'Inspect actuator air supply'),
        ],
        estimatedDuration: const Duration(minutes: 45),
        instructions:
            'Coordinate with control room before stroke test. '
            'Do not leave valve mid-travel.',
        status: PmPlanStatus.overdue,
        lastCompleted: DateTime(2026, 9, 15),
      ),
      PmPlan(
        id: 'PM-1004',
        assetId: 'AST-1005',
        assetName: 'H2S Detector North',
        maintenanceType: 'Calibration',
        frequency: PmFrequency.monthly,
        startDate: DateTime(2026, 2, 10),
        nextDueDate: DateTime(2026, 10, 10),
        assignedTeam: 'Instrumentation',
        assignedTechnician: 'Sam Okonkwo',
        priority: PmPriority.high,
        checklist: const [
          PmChecklistItem(id: 'c1', label: 'Bump test with H2S'),
          PmChecklistItem(id: 'c2', label: 'Check alarm setpoints'),
          PmChecklistItem(id: 'c3', label: 'Inspect wiring / gland'),
        ],
        estimatedDuration: const Duration(hours: 1),
        instructions: 'Wear H2S monitor. Evacuate area if live gas present.',
        status: PmPlanStatus.dueSoon,
        lastCompleted: DateTime(2026, 9, 10),
      ),
      PmPlan(
        id: 'PM-1005',
        assetId: 'AST-1004',
        assetName: 'ADNOC 701',
        maintenanceType: 'Inspection',
        frequency: PmFrequency.halfYearly,
        startDate: DateTime(2026, 4, 1),
        nextDueDate: DateTime(2026, 10, 1),
        assignedTeam: 'Mechanical Team',
        assignedTechnician: 'Unassigned',
        priority: PmPriority.medium,
        checklist: const [
          PmChecklistItem(id: 'c1', label: 'Airframe visual inspection'),
          PmChecklistItem(id: 'c2', label: 'Review flight hours log'),
          PmChecklistItem(id: 'c3', label: 'Check life-limited parts'),
        ],
        estimatedDuration: const Duration(hours: 4),
        instructions: 'Follow OEM checklist chapter 5. Log findings in CAM.',
        status: PmPlanStatus.scheduled,
        lastCompleted: DateTime(2026, 4, 1),
      ),
      PmPlan(
        id: 'PM-1006',
        assetId: 'AST-1006',
        assetName: 'Charge Pump A',
        maintenanceType: 'Lubrication',
        frequency: PmFrequency.weekly,
        startDate: DateTime(2026, 9, 1),
        nextDueDate: DateTime(2026, 10, 6),
        assignedTeam: 'Mechanical Team',
        assignedTechnician: 'Alex Rivera',
        priority: PmPriority.low,
        checklist: const [
          PmChecklistItem(id: 'c1', label: 'Grease drive end bearing'),
          PmChecklistItem(id: 'c2', label: 'Grease non-drive end bearing'),
          PmChecklistItem(id: 'c3', label: 'Wipe excess grease'),
        ],
        estimatedDuration: const Duration(minutes: 30),
        instructions: 'Use lithium complex grease only. Do not over-grease.',
        status: PmPlanStatus.scheduled,
        lastCompleted: DateTime(2026, 9, 29),
      ),
    ];
  }
}
