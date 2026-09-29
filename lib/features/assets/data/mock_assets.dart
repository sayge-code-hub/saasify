import 'package:saasify/features/assets/domain/asset.dart';

/// In-memory seed catalog for Asset Management MVP 1.
abstract final class MockAssets {
  static const types = <String>[
    'digital_input',
    'gas',
    'h2s',
    'Helicopter',
    'pump',
    'valve',
    'sensor',
  ];

  static const locations = <String>[
    'utilities',
    'inlet_separators',
    'plant_a',
    'plant_b',
    'offshore_pad_1',
    'warehouse',
  ];

  static List<Asset> createCatalog() {
    const ait = Asset(
      id: 'AST-1001',
      name: 'AIT-1000',
      assetTag: 'ait_1000',
      type: 'gas',
      location: 'inlet_separators',
      status: AssetStatus.inService,
    );
    return [
      ait,
      const Asset(
        id: 'AST-1002',
        name: 'AC Fail',
        assetTag: 'bac_6000',
        type: 'digital_input',
        location: 'utilities',
        status: AssetStatus.inService,
      ),
      const Asset(
        id: 'AST-1003',
        name: 'Acheck',
        assetTag: 'acheck_01',
        type: 'digital_input',
        location: 'utilities',
        status: AssetStatus.maintenance,
      ),
      Asset(
        id: 'AST-1004',
        name: 'ADNOC 701',
        assetTag: 'adnoc_701',
        type: 'Helicopter',
        location: 'offshore_pad_1',
        status: AssetStatus.inService,
        parentId: ait.id,
        parentName: ait.name,
        parentTag: ait.assetTag,
      ),
      Asset(
        id: 'AST-1005',
        name: 'H2S Detector North',
        assetTag: 'h2s_n_12',
        type: 'h2s',
        location: 'plant_a',
        status: AssetStatus.inService,
        parentId: ait.id,
        parentName: ait.name,
        parentTag: ait.assetTag,
      ),
      const Asset(
        id: 'AST-1006',
        name: 'Charge Pump A',
        assetTag: 'pump_chg_a',
        type: 'pump',
        location: 'plant_b',
        status: AssetStatus.outOfService,
      ),
      const Asset(
        id: 'AST-1007',
        name: 'ESD Valve 14',
        assetTag: 'esd_v_14',
        type: 'valve',
        location: 'plant_a',
        status: AssetStatus.inService,
      ),
      const Asset(
        id: 'AST-1008',
        name: 'Temp Sensor Bay 3',
        assetTag: 'tmp_bay_3',
        type: 'sensor',
        location: 'warehouse',
        status: AssetStatus.decommissioned,
      ),
    ];
  }
}
