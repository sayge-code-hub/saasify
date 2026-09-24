import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_spacing.dart';

enum AppButtonVariant { filled, outlined, text }

/// Primary reusable button with consistent sizing and variants.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : _labelRow();

    final effectiveOnPressed = isLoading ? null : onPressed;

    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _labelRow() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Text(label),
      ],
    );
  }
}
