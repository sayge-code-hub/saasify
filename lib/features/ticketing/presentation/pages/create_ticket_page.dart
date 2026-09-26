import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

/// Form to create a new support ticket / case (mocked in memory).
class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  final _customerName = TextEditingController();
  final _customerEmail = TextEditingController();
  TicketPriority _priority = TicketPriority.medium;
  bool _submitting = false;

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    _customerName.dispose();
    _customerEmail.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final id = context.read<TicketListCubit>().createTicket(
          subject: _subject.text,
          description: _description.text,
          customerName: _customerName.text,
          customerEmail: _customerEmail.text,
          priority: _priority,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Case $id created.')),
    );
    context.go('/ticketing/tickets/$id');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPage(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add new ticket',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create a support case for a customer. Saved to the mock queue.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _subject,
                      label: 'Subject',
                      hint: 'Short summary of the issue',
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Subject is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _description,
                      label: 'Description',
                      hint: 'What happened, and what should happen next?',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _customerName,
                            label: 'Customer name',
                            hint: 'Full name',
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            controller: _customerEmail,
                            label: 'Customer email',
                            hint: 'name@company.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Email is required';
                              if (!v.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Priority',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final priority in TicketPriority.values)
                          ChoiceChip(
                            label: Text(priority.label),
                            selected: _priority == priority,
                            selectedColor: AppColors.accentMuted,
                            labelStyle: theme.textTheme.labelLarge?.copyWith(
                              color: _priority == priority
                                  ? AppColors.accentHover
                                  : AppColors.inkSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: _priority == priority
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                            onSelected: (_) =>
                                setState(() => _priority = priority),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        AppButton(
                          label: 'Create case',
                          icon: Icons.add,
                          isLoading: _submitting,
                          onPressed: _submitting ? null : _submit,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: 'Cancel',
                          variant: AppButtonVariant.outlined,
                          onPressed: _submitting
                              ? null
                              : () => context.go('/ticketing'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
