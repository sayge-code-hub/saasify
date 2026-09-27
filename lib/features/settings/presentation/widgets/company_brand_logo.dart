import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/settings/presentation/bloc/company_logo_cubit.dart';

/// Sidebar brand slot: uploaded company logo or a muted placeholder.
class CompanyBrandLogo extends StatelessWidget {
  const CompanyBrandLogo({
    this.height = 28,
    super.key,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyLogoCubit, Uint8List?>(
      builder: (context, bytes) {
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            key: const ValueKey('company-logo-image'),
            height: height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            semanticLabel: 'Company logo',
          );
        }
        return _CompanyLogoPlaceholder(height: height);
      },
    );
  }
}

class _CompanyLogoPlaceholder extends StatelessWidget {
  const _CompanyLogoPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      key: const ValueKey('company-logo-placeholder'),
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.apartment_outlined,
              size: height * 0.55,
              color: AppColors.inkTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Your logo',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.inkTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
