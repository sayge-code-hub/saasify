import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_theme.dart';

void main() {
  test('light theme uses teal primary and canvas scaffold', () {
    final theme = AppTheme.light();

    expect(theme.colorScheme.primary, AppColors.accent);
    expect(theme.scaffoldBackgroundColor, AppColors.canvas);
    expect(theme.brightness, Brightness.light);
    expect(theme.useMaterial3, isTrue);
  });
}
