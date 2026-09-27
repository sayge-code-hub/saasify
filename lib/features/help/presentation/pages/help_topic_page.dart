import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/help/domain/help_topics.dart';

/// Detail form for one Help module.
class HelpTopicPage extends StatefulWidget {
  const HelpTopicPage({required this.topic, super.key});

  final HelpTopic topic;

  @override
  State<HelpTopicPage> createState() => _HelpTopicPageState();
}

class _HelpTopicPageState extends State<HelpTopicPage> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message before submitting.')),
      );
      return;
    }
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.topic.title} submitted (mock).')),
    );
    context.go('/help');
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('help-topic-back'),
              onPressed: () => context.go('/help'),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back to Help'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(topic.icon, color: AppColors.inkSecondary, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  topic.title,
                  variant: AppTextVariant.pageTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            topic.description,
            variant: AppTextVariant.pageSubtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppText('Message', variant: AppTextVariant.label),
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField(
                    key: const ValueKey('help-topic-message'),
                    controller: _controller,
                    hint: topic.formHint,
                    maxLines: 6,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      key: const ValueKey('help-topic-submit'),
                      label: topic.submitLabel,
                      isLoading: _submitting,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
