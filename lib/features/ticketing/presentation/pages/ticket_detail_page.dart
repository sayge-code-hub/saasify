import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/ticketing/data/mock_tickets.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_badges.dart';

class TicketDetailPage extends StatefulWidget {
  const TicketDetailPage({required this.ticketId, super.key});

  final String ticketId;

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = context.isCompact;

    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        final ticket = state.byId(widget.ticketId);
        if (ticket == null) {
          return AppPage(
            child: AppEmptyState(
              title: 'Ticket not found',
              message: 'This ticket may have been removed from the mock set.',
              actionLabel: 'Back to tickets',
              onAction: () => context.go('/ticketing'),
            ),
          );
        }

        final agentName = switch (context.read<AuthCubit>().state) {
          AuthAuthenticated(:final user) => user.name,
          _ => 'Agent',
        };

        final meta = _TicketMetaPanel(ticket: ticket);
        final thread = _ConversationPanel(
          ticket: ticket,
          replyController: _replyController,
          agentName: agentName,
        );

        return AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/ticketing'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('All tickets'),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(ticket.id, style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
              )),
              const SizedBox(height: AppSpacing.xxs),
              Text(ticket.subject, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  TicketStatusBadge(status: ticket.status),
                  TicketPriorityBadge(priority: ticket.priority),
                  for (final tag in ticket.tags)
                    Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: AppColors.border),
                      backgroundColor: AppColors.surfaceMuted,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _WorkflowBar(ticket: ticket),
              const SizedBox(height: AppSpacing.lg),
              if (compact) ...[
                thread,
                const SizedBox(height: AppSpacing.lg),
                meta,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: thread),
                    const SizedBox(width: AppSpacing.lg),
                    SizedBox(width: 300, child: meta),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkflowBar extends StatelessWidget {
  const _WorkflowBar({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TicketListCubit>();
    final next = ticket.status.next;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Workflow',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (next != null)
              AppButton(
                label: 'Mark ${next.label.toLowerCase()}',
                icon: Icons.play_arrow_rounded,
                onPressed: () => cubit.updateStatus(ticket.id, next),
              ),
            AppButton(
              label: 'Resolve',
              variant: AppButtonVariant.outlined,
              onPressed: ticket.status == TicketStatus.resolved ||
                      ticket.status == TicketStatus.closed
                  ? null
                  : () => cubit.updateStatus(
                        ticket.id,
                        TicketStatus.resolved,
                      ),
            ),
            AppButton(
              label: 'Close',
              variant: AppButtonVariant.text,
              onPressed: ticket.status == TicketStatus.closed
                  ? null
                  : () => cubit.updateStatus(
                        ticket.id,
                        TicketStatus.closed,
                      ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DropdownButton<String?>(
              value: ticket.assigneeName?.isEmpty == true
                  ? null
                  : ticket.assigneeName,
              hint: const Text('Assign agent'),
              underline: const SizedBox.shrink(),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Unassigned'),
                ),
                for (final name in MockTickets.assignees)
                  DropdownMenuItem<String?>(value: name, child: Text(name)),
              ],
              onChanged: (value) => cubit.assign(ticket.id, value ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationPanel extends StatelessWidget {
  const _ConversationPanel({
    required this.ticket,
    required this.replyController,
    required this.agentName,
  });

  final Ticket ticket;
  final TextEditingController replyController;
  final String agentName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<TicketListCubit>();

    return DecoratedBox(
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
            Text('Conversation', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            for (final message in ticket.messages) ...[
              _MessageBubble(message: message),
              const SizedBox(height: AppSpacing.sm),
            ],
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Text('Reply as $agentName', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: replyController,
              hint: 'Write an internal or customer-facing reply…',
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Send reply',
                icon: Icons.send_outlined,
                onPressed: () {
                  cubit.addReply(
                    ticketId: ticket.id,
                    body: replyController.text,
                    agentName: agentName,
                  );
                  replyController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final TicketMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final align =
        message.isAgent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = message.isAgent ? AppColors.accentMuted : AppColors.canvasTint;

    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          '${message.authorName} · ${_formatTime(message.createdAt)}',
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(message.body, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  String _formatTime(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '${value.month}/${value.day} $h:$m';
  }
}

class _TicketMetaPanel extends StatelessWidget {
  const _TicketMetaPanel({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _MetaRow(label: 'Customer', value: ticket.customerName),
            _MetaRow(label: 'Email', value: ticket.customerEmail),
            _MetaRow(
              label: 'Assignee',
              value: ticket.assigneeName?.isNotEmpty == true
                  ? ticket.assigneeName!
                  : 'Unassigned',
            ),
            _MetaRow(
              label: 'Created',
              value: _formatDate(ticket.createdAt),
            ),
            _MetaRow(
              label: 'Updated',
              value: _formatDate(ticket.updatedAt),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Description', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(ticket.description, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
