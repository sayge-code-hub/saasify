import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// Compact “Powered by Sayge” + version footer for nav and login.
class PoweredByFooter extends StatelessWidget {
  const PoweredByFooter({
    this.align = Alignment.center,
    this.compact = true,
    super.key,
  });

  final AlignmentGeometry align;
  final bool compact;

  Future<void> _openSayge() async {
    final uri = Uri.parse(AppConstants.saygeUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: AppColors.inkTertiary,
      fontSize: compact ? 10 : 11,
      height: 1.3,
      fontWeight: FontWeight.w500,
    );

    return Align(
      alignment: align,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              style: style,
              children: [
                const TextSpan(text: AppConstants.poweredByPrefix),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    key: const ValueKey('powered-by-sayge'),
                    onTap: _openSayge,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        AppConstants.saygeLabel,
                        style: style?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          GestureDetector(
            key: const ValueKey('app-version-link'),
            onTap: () => context.go('/releases'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                child: Text(
                  AppConstants.appVersionLabel,
                  style: style?.copyWith(
                    color: AppColors.inkSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.inkTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
