import 'package:equatable/equatable.dart';

enum AssetStatus {
  inService,
  outOfService,
  maintenance,
  decommissioned,
}

extension AssetStatusX on AssetStatus {
  String get label => switch (this) {
        AssetStatus.inService => 'In Service',
        AssetStatus.outOfService => 'Out of Service',
        AssetStatus.maintenance => 'Maintenance',
        AssetStatus.decommissioned => 'Decommissioned',
      };
}

class Asset extends Equatable {
  const Asset({
    required this.id,
    required this.name,
    required this.assetTag,
    required this.type,
    required this.location,
    required this.status,
    this.parentId,
    this.parentName,
    this.parentTag,
  });

  final String id;
  final String name;
  final String assetTag;
  final String type;
  final String location;
  final AssetStatus status;
  final String? parentId;
  final String? parentName;
  final String? parentTag;

  String get parentLabel {
    if (parentName == null || parentName!.isEmpty) return '—';
    final tag = parentTag;
    if (tag == null || tag.isEmpty) return parentName!;
    return '$parentName [$tag]';
  }

  Asset copyWith({
    String? id,
    String? name,
    String? assetTag,
    String? type,
    String? location,
    AssetStatus? status,
    String? parentId,
    String? parentName,
    String? parentTag,
    bool clearParent = false,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      assetTag: assetTag ?? this.assetTag,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this.status,
      parentId: clearParent ? null : parentId ?? this.parentId,
      parentName: clearParent ? null : parentName ?? this.parentName,
      parentTag: clearParent ? null : parentTag ?? this.parentTag,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        assetTag,
        type,
        location,
        status,
        parentId,
        parentName,
        parentTag,
      ];
}
