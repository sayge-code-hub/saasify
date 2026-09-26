import 'package:flutter/material.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';

/// Constrains page content width and applies responsive padding.
class AppPage extends StatelessWidget {
  const AppPage({
    required this.child,
    this.maxWidth = AppSpacing.contentMaxWidth,
    this.scrollable = true,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.isCompact
        ? AppSpacing.pagePaddingCompact
        : AppSpacing.pagePaddingExpanded;

    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSpacing.xxl,
            horizontal,
            AppSpacing.lg,
          ),
          child: child,
        ),
      ),
    );

    final body = scrollable ? SingleChildScrollView(child: content) : content;
    return ColoredBox(color: AppColors.canvas, child: body);
  }
}
