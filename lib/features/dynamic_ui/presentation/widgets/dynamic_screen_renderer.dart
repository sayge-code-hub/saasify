import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_loading.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/features/dynamic_ui/domain/dynamic_screen.dart';
import 'package:saasify/features/dynamic_ui/presentation/bloc/dynamic_screen_cubit.dart';
import 'package:saasify/features/dynamic_ui/presentation/widgets/dynamic_action_handler.dart';

/// Renders a [DynamicScreenConfig] as a form card + sticky action bar.
class DynamicScreenRenderer extends StatefulWidget {
  const DynamicScreenRenderer({super.key});

  @override
  State<DynamicScreenRenderer> createState() => _DynamicScreenRendererState();
}

class _DynamicScreenRendererState extends State<DynamicScreenRenderer> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicScreenCubit, DynamicScreenState>(
      builder: (context, state) {
        if (state.status == DynamicScreenStatus.loading ||
            state.status == DynamicScreenStatus.initial) {
          return const AppLoading(message: 'Loading screen…');
        }
        if (state.status == DynamicScreenStatus.failure ||
            state.config == null) {
          return AppEmptyState(
            title: 'Screen unavailable',
            message: state.errorMessage ?? 'Could not load dynamic screen.',
            actionLabel: 'Retry',
            onAction: () => context.read<DynamicScreenCubit>().load(),
          );
        }

        final config = state.config!;
        final compact = context.isCompact;
        final handler = DynamicActionHandler(context);

        return ColoredBox(
          color: AppColors.canvas,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth =
                          constraints.maxWidth * config.cardWidthFactor;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          AppSpacing.pageContentTop,
                          0,
                          AppSpacing.lg,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: cardWidth,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                                border: Border.all(color: AppColors.border),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.lg,
                                  AppSpacing.xl,
                                  AppSpacing.lg,
                                  AppSpacing.lg,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppText(
                                      config.title,
                                      variant: AppTextVariant.pageTitle,
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    for (final row in config.rows) ...[
                                      _DynamicRow(
                                        row: row,
                                        compact: compact,
                                        values: state.values,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (config.stickyActions)
                  _StickyActions(
                    buttons: config.buttons,
                    busy: state.busy,
                    alignEnd: config.actionsAlign != 'start',
                    onPressed: (button) => handler.run(
                      button.onClick,
                      validateForm: button.validateForm,
                      formKey: _formKey,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _ButtonRow(
                      buttons: config.buttons,
                      busy: state.busy,
                      alignEnd: config.actionsAlign != 'start',
                      onPressed: (button) => handler.run(
                        button.onClick,
                        validateForm: button.validateForm,
                        formKey: _formKey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StickyActions extends StatelessWidget {
  const _StickyActions({
    required this.buttons,
    required this.busy,
    required this.alignEnd,
    required this.onPressed,
  });

  final List<DynamicButtonConfig> buttons;
  final bool busy;
  final bool alignEnd;
  final ValueChanged<DynamicButtonConfig> onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: _ButtonRow(
              buttons: buttons,
              busy: busy,
              alignEnd: alignEnd,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({
    required this.buttons,
    required this.busy,
    required this.alignEnd,
    required this.onPressed,
  });

  final List<DynamicButtonConfig> buttons;
  final bool busy;
  final bool alignEnd;
  final ValueChanged<DynamicButtonConfig> onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
        children: [
          for (final button in buttons)
            AppButton(
              key: ValueKey('dynamic-btn-${button.id}'),
              label: button.label,
              variant: mapButtonVariant(button.variant),
              isLoading: busy && button.variant == DynamicButtonVariant.filled,
              onPressed: busy ? null : () => onPressed(button),
            ),
        ],
      ),
    );
  }
}

class _DynamicRow extends StatelessWidget {
  const _DynamicRow({
    required this.row,
    required this.compact,
    required this.values,
  });

  final DynamicRowConfig row;
  final bool compact;
  final Map<String, String> values;

  @override
  Widget build(BuildContext context) {
    if (compact || row.fields.length == 1) {
      return Column(
        children: [
          for (var i = 0; i < row.fields.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _DynamicField(field: row.fields[i], value: values[row.fields[i].key]),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < row.fields.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.lg),
          Expanded(
            flex: row.fields[i].flex,
            child: _DynamicField(
              field: row.fields[i],
              value: values[row.fields[i].key],
            ),
          ),
        ],
      ],
    );
  }
}

class _DynamicField extends StatelessWidget {
  const _DynamicField({required this.field, this.value});

  final DynamicFieldConfig field;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = context.isCompact;
    final cubit = context.read<DynamicScreenCubit>();

    final label = Text.rich(
      TextSpan(
        text: field.label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (field.required)
            const TextSpan(
              text: '*',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );

    final control = switch (field.type) {
      DynamicFieldType.text || DynamicFieldType.textarea => TextFormField(
          key: ValueKey('dynamic-field-${field.key}'),
          initialValue: value,
          maxLines: field.type == DynamicFieldType.textarea
              ? field.maxLines
              : 1,
          decoration: _decoration(field.hint),
          onChanged: (v) => cubit.setValue(field.key, v),
          validator: (v) {
            if (field.required && (v == null || v.trim().isEmpty)) {
              return '${field.label} is required';
            }
            return null;
          },
        ),
      DynamicFieldType.dropdown => DropdownButtonFormField<String>(
          key: ValueKey('dynamic-field-${field.key}'),
          // ignore: deprecated_member_use
          value: value != null &&
                  field.options.any((o) => o.value == value)
              ? value
              : null,
          isExpanded: true,
          decoration: _decoration(field.hint),
          items: [
            for (final option in field.options)
              DropdownMenuItem(
                value: option.value,
                child: Text(option.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => cubit.setValue(field.key, v),
          validator: (v) {
            if (field.required && (v == null || v.isEmpty)) {
              return '${field.label} is required';
            }
            return null;
          },
        ),
      DynamicFieldType.radio => FormField<String>(
          key: ValueKey('dynamic-field-${field.key}'),
          initialValue: value,
          validator: (v) {
            if (field.required && (v == null || v.isEmpty)) {
              return '${field.label} is required';
            }
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  children: [
                    for (final option in field.options)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: option.value,
                            // ignore: deprecated_member_use
                            groupValue: state.value ?? value,
                            // ignore: deprecated_member_use
                            onChanged: (v) {
                              state.didChange(v);
                              cubit.setValue(field.key, v);
                            },
                          ),
                          Text(option.label),
                        ],
                      ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      state.errorText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
    };

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label,
          const SizedBox(height: AppSpacing.xs),
          control,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: field.type == DynamicFieldType.textarea ||
                  field.type == DynamicFieldType.radio
              ? 140
              : 128,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: label,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: control),
      ],
    );
  }

  InputDecoration _decoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }
}
