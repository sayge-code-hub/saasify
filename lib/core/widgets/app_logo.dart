import 'package:flutter/material.dart';

import 'package:saasify/core/constants/app_constants.dart';

/// Brand mark from `assets/brand/logo_mark.png` (group.svg source).
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({
    this.size = 40,
    this.semanticLabel = '${AppConstants.appName} logo',
    super.key,
  });

  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/logo_mark.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
      semanticLabel: semanticLabel,
    );
  }
}

/// Horizontal wordmark from `assets/brand/logo_wordmark.png`.
class AppLogoWordmark extends StatelessWidget {
  const AppLogoWordmark({
    this.height = 36,
    this.semanticLabel = AppConstants.appName,
    super.key,
  });

  final double height;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/logo_wordmark.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: semanticLabel,
    );
  }
}
