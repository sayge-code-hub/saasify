import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/assets/domain/asset.dart';

class AssetStatusChip extends StatelessWidget {
  const AssetStatusChip({required this.status, super.key});

  final AssetStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      AssetStatus.inService => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      AssetStatus.maintenance => (AppColors.accentMuted, AppColors.accentHover),
      AssetStatus.outOfService => (const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
      AssetStatus.decommissioned => (AppColors.surfaceMuted, AppColors.inkTertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
