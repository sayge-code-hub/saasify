import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/features/assets/data/mock_assets.dart';
import 'package:saasify/features/assets/domain/asset.dart';

class AssetListState extends Equatable {
  const AssetListState({
    required this.assets,
    this.query = '',
  });

  final List<Asset> assets;
  final String query;

  List<Asset> get visible {
    final q = query.trim().toLowerCase();
    final filtered = assets.where((asset) {
      if (q.isEmpty) return true;
      return asset.name.toLowerCase().contains(q) ||
          asset.assetTag.toLowerCase().contains(q) ||
          asset.type.toLowerCase().contains(q) ||
          asset.location.toLowerCase().contains(q) ||
          asset.id.toLowerCase().contains(q) ||
          asset.parentLabel.toLowerCase().contains(q);
    }).toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return filtered;
  }

  Asset? byId(String id) {
    for (final asset in assets) {
      if (asset.id == id) return asset;
    }
    return null;
  }

  List<Asset> childrenOf(String? parentId) {
    return assets.where((a) => a.parentId == parentId).toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }

  List<Asset> get roots => childrenOf(null);

  AssetListState copyWith({
    List<Asset>? assets,
    String? query,
  }) {
    return AssetListState(
      assets: assets ?? this.assets,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [assets, query];
}

class AssetListCubit extends Cubit<AssetListState> {
  AssetListCubit({List<Asset>? seed})
      : super(AssetListState(assets: seed ?? MockAssets.createCatalog()));

  void setQuery(String query) => emit(state.copyWith(query: query));

  String createAsset({
    required String name,
    required String assetTag,
    required String type,
    required String location,
    required AssetStatus status,
    String? parentId,
  }) {
    final id = _nextId();
    final parent = parentId == null ? null : state.byId(parentId);
    final asset = Asset(
      id: id,
      name: name.trim(),
      assetTag: assetTag.trim(),
      type: type.trim(),
      location: location.trim(),
      status: status,
      parentId: parent?.id,
      parentName: parent?.name,
      parentTag: parent?.assetTag,
    );
    emit(state.copyWith(assets: [asset, ...state.assets]));
    return id;
  }

  void updateAsset(Asset updated) {
    final parent = updated.parentId == null
        ? null
        : state.byId(updated.parentId!);
    final normalized = updated.copyWith(
      parentId: parent?.id,
      parentName: parent?.name,
      parentTag: parent?.assetTag,
      clearParent: updated.parentId == null,
    );
    emit(
      state.copyWith(
        assets: [
          for (final asset in state.assets)
            if (asset.id == normalized.id) normalized else asset,
        ],
      ),
    );
  }

  void deleteAsset(String id) {
    emit(
      state.copyWith(
        assets: [
          for (final asset in state.assets)
            if (asset.id != id)
              asset.parentId == id
                  ? asset.copyWith(clearParent: true)
                  : asset,
        ],
      ),
    );
  }

  String _nextId() {
    var max = 1000;
    for (final asset in state.assets) {
      final raw = asset.id.replaceFirst('AST-', '');
      final value = int.tryParse(raw);
      if (value != null && value > max) max = value;
    }
    return 'AST-${max + 1}';
  }
}
