import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/features/ticketing/data/mock_tickets.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

/// Create-ticket form matching the field set: Header, Application, Priority,
/// Bug, Responsibility, Affected Equipment, Description, Distribution List.
class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _header = TextEditingController();
  final _description = TextEditingController();
  final _responsibility = TextEditingController();
  final _affectedEquipment = TextEditingController();

  TicketPriority? _priority;
  String? _application;
  String _bug = 'No';
  String? _distributionList;
  bool _submitting = false;

  @override
  void dispose() {
    _header.dispose();
    _description.dispose();
    _responsibility.dispose();
    _affectedEquipment.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_priority == null || _application == null || _distributionList == null) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() => _submitting = true);

    final id = context.read<TicketListCubit>().createTicket(
          subject: _header.text,
          description: _description.text,
          priority: _priority!,
          application: _application!,
          distributionList: _distributionList!,
          isBug: _bug == 'Yes',
          responsibility: _responsibility.text,
          affectedEquipment: _affectedEquipment.text,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket $id saved.')),
    );
    context.go('/ticketing/tickets/$id');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = context.isCompact;

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
                  final cardWidth = constraints.maxWidth * 0.95;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: cardWidth,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Create Ticket',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                _FormGrid(
                                  compact: compact,
                                  children: [
                                    _LabeledField(
                                      label: 'Header',
                                      required: true,
                                      child: TextFormField(
                                        key: const ValueKey('ticket-header'),
                                        controller: _header,
                                        textInputAction: TextInputAction.next,
                                        decoration: _inputDecoration(),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Header is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    _LabeledField(
                                      label: 'Application',
                                      required: true,
                                      child: DropdownButtonFormField<String>(
                                        key: const ValueKey(
                                          'ticket-application',
                                        ),
                                        // ignore: deprecated_member_use
                                        value: _application,
                                        isExpanded: true,
                                        decoration: _inputDecoration(
                                          hint: '--- select application ---',
                                        ),
                                        items: [
                                          for (final app
                                              in MockTickets.applications)
                                            DropdownMenuItem(
                                              value: app,
                                              child: Text(
                                                app,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                        onChanged: (value) => setState(
                                          () => _application = value,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Application is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    _LabeledField(
                                      label: 'Priority',
                                      required: true,
                                      child: DropdownButtonFormField<
                                          TicketPriority>(
                                        key: const ValueKey('ticket-priority'),
                                        // ignore: deprecated_member_use
                                        value: _priority,
                                        isExpanded: true,
                                        decoration: _inputDecoration(
                                          hint: '--- select priority ---',
                                        ),
                                        items: [
                                          for (final p
                                              in TicketPriority.values)
                                            DropdownMenuItem(
                                              value: p,
                                              child: Text(p.label),
                                            ),
                                        ],
                                        onChanged: (value) =>
                                            setState(() => _priority = value),
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Priority is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    _LabeledField(
                                      label: 'Bug',
                                      required: true,
                                      child: DropdownButtonFormField<String>(
                                        key: const ValueKey('ticket-bug'),
                                        // ignore: deprecated_member_use
                                        value: _bug,
                                        isExpanded: true,
                                        decoration: _inputDecoration(),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'No',
                                            child: Text('No'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Yes',
                                            child: Text('Yes'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() => _bug = value);
                                          }
                                        },
                                      ),
                                    ),
                                    _LabeledField(
                                      label: 'Responsibility',
                                      child: TextFormField(
                                        key: const ValueKey(
                                          'ticket-responsibility',
                                        ),
                                        controller: _responsibility,
                                        textInputAction: TextInputAction.next,
                                        decoration: _inputDecoration(),
                                      ),
                                    ),
                                    _LabeledField(
                                      label: 'Affected Equipment',
                                      child: TextFormField(
                                        key: const ValueKey(
                                          'ticket-equipment',
                                        ),
                                        controller: _affectedEquipment,
                                        textInputAction: TextInputAction.next,
                                        decoration: _inputDecoration(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _LabeledField(
                                  label: 'Description',
                                  required: true,
                                  labelWidth: compact ? null : 140,
                                  child: TextFormField(
                                    key: const ValueKey('ticket-description'),
                                    controller: _description,
                                    maxLines: 6,
                                    decoration: _inputDecoration(),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Description is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _LabeledField(
                                  label: 'Distribution List',
                                  required: true,
                                  labelWidth: compact ? null : 140,
                                  child: DropdownButtonFormField<String>(
                                    key: const ValueKey('ticket-distribution'),
                                    // ignore: deprecated_member_use
                                    value: _distributionList,
                                    isExpanded: true,
                                    decoration: _inputDecoration(
                                      hint: 'Choose option',
                                    ),
                                    items: [
                                      for (final list
                                          in MockTickets.distributionLists)
                                        DropdownMenuItem(
                                          value: list,
                                          child: Text(
                                            list,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                    onChanged: (value) => setState(
                                      () => _distributionList = value,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Distribution list is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                ),
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
            Material(
              color: AppColors.surface,
              elevation: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        alignment: WrapAlignment.end,
                        children: [
                          AppButton(
                            label: 'Cancel',
                            variant: AppButtonVariant.outlined,
                            onPressed: _submitting
                                ? null
                                : () => context.go('/ticketing'),
                          ),
                          AppButton(
                            label: 'Save',
                            isLoading: _submitting,
                            onPressed: _submitting ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
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

class _FormGrid extends StatelessWidget {
  const _FormGrid({required this.compact, required this.children});

  final bool compact;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            children[i],
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final left = children[i];
      final right = i + 1 < children.length ? children[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: i + 2 < children.length ? AppSpacing.md : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: right ?? const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.required = false,
    this.labelWidth,
  });

  final String label;
  final Widget child;
  final bool required;
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = context.isCompact;
    final labelText = Text.rich(
      TextSpan(
        text: label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (required)
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

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          labelText,
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth ?? 128,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: labelText,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}
