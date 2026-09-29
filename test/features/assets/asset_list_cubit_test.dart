import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saasify/features/assets/domain/asset.dart';
import 'package:saasify/features/assets/presentation/bloc/asset_list_cubit.dart';

void main() {
  group('AssetListCubit', () {
    blocTest<AssetListCubit, AssetListState>(
      'filters by query',
      build: AssetListCubit.new,
      act: (cubit) => cubit.setQuery('pump'),
      expect: () => [
        isA<AssetListState>().having(
          (s) => s.visible.every(
            (a) =>
                a.name.toLowerCase().contains('pump') ||
                a.assetTag.toLowerCase().contains('pump'),
          ),
          'visible matches pump',
          true,
        ),
      ],
    );

    blocTest<AssetListCubit, AssetListState>(
      'creates and deletes assets',
      build: AssetListCubit.new,
      act: (cubit) {
        final id = cubit.createAsset(
          name: 'New Valve',
          assetTag: 'nv_01',
          type: 'valve',
          location: 'plant_a',
          status: AssetStatus.inService,
        );
        cubit.deleteAsset(id);
      },
      verify: (cubit) {
        expect(cubit.state.byId('AST-1009'), isNull);
        expect(
          cubit.state.assets.any((a) => a.assetTag == 'nv_01'),
          isFalse,
        );
      },
    );
  });
}
