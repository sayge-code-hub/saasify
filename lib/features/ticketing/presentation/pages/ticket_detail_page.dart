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
              onAction: () => context.go('/ticketing/all'),
            ),
          );
        }

        final agentName = switch (context.read<AuthCubit>().state) {
          AuthAuthenticated(:final user) => user.name,
          _ => 'Agent',
        };

        final mainColumn = _TicketMainColumn(
          ticket: ticket,
          replyController: _replyController,
          agentName: agentName,
        );
        final sideColumn = _TicketSideColumn(
          attachments: ticket.attachments,
          events: ticket.events,
        );

        return AppPage(
          maxWidth: 1280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ticket.id,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
              if (compact) ...[
                mainColumn,
                const SizedBox(height: AppSpacing.lg),
                sideColumn,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: mainColumn),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 3, child: sideColumn),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Left ~70%: details + comments.
class _TicketMainColumn extends StatelessWidget {
  const _TicketMainColumn({
    required this.ticket,
    required this.replyController,
    required this.agentName,
  });

  final Ticket ticket;
  final TextEditingController replyController;
  final String agentName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailsSection(ticket: ticket),
        const SizedBox(height: AppSpacing.lg),
        _CommentsPanel(
          ticket: ticket,
          replyController: replyController,
          agentName: agentName,
        ),
      ],
    );
  }
}

/// Right ~30%: attachments on top, activity ledger below.
class _TicketSideColumn extends StatelessWidget {
  const _TicketSideColumn({
    required this.attachments,
    required this.events,
  });

  final List<TicketAttachment> attachments;
  final List<TicketEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AttachmentsSection(attachments: attachments),
        const SizedBox(height: AppSpacing.md),
        _ActivityLedger(events: events),
      ],
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.ticket});

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
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 520;
                final rows = [
                  _MetaRow(label: 'Customer', value: ticket.customerName),
                  _MetaRow(label: 'Email', value: ticket.customerEmail),
                  _MetaRow(
                    label: 'Assignee',
                    value: ticket.assigneeName?.isNotEmpty == true
                        ? ticket.assigneeName!
                        : 'Unassigned',
                  ),
                  _MetaRow(
                    label: 'Application',
                    value: ticket.application?.isNotEmpty == true
                        ? ticket.application!
                        : '—',
                  ),
                  _MetaRow(
                    label: 'Bug',
                    value: ticket.isBug ? 'Yes' : 'No',
                  ),
                  _MetaRow(
                    label: 'Responsibility',
                    value: ticket.responsibility?.isNotEmpty == true
                        ? ticket.responsibility!
                        : '—',
                  ),
                  _MetaRow(
                    label: 'Affected Equipment',
                    value: ticket.affectedEquipment?.isNotEmpty == true
                        ? ticket.affectedEquipment!
                        : '—',
                  ),
                  _MetaRow(
                    label: 'Distribution List',
                    value: ticket.distributionList?.isNotEmpty == true
                        ? ticket.distributionList!
                        : '—',
                  ),
                  _MetaRow(
                    label: 'Created',
                    value: _formatDate(ticket.createdAt),
                  ),
                  _MetaRow(
                    label: 'Updated',
                    value: _formatDate(ticket.updatedAt),
                  ),
                  _MetaRow(
                    label: 'Priority',
                    value: ticket.priority.label,
                  ),
                  _MetaRow(
                    label: 'Status',
                    value: ticket.status.label,
                  ),
                ];

                if (!twoCol) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rows,
                  );
                }

                return Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final row in rows)
                      SizedBox(
                        width: (constraints.maxWidth - AppSpacing.xl) / 2,
                        child: row,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Description',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(ticket.description, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _CommentsPanel extends StatelessWidget {
  const _CommentsPanel({
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
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Comments', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (ticket.messages.isEmpty)
              Text(
                'No comments yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkTertiary,
                ),
              )
            else
              for (final message in ticket.messages) ...[
                _CommentRow(message: message),
                const SizedBox(height: AppSpacing.xs),
              ],
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Comment as $agentName',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            AppTextField(
              controller: replyController,
              hint: 'Add a comment…',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Send',
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

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.message});

  final TicketMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = message.isAgent ? AppColors.accentMuted : AppColors.surfaceMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${message.authorName} · ${_formatTime(message.createdAt)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.inkSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(message.body, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  const _AttachmentsSection({required this.attachments});

  final List<TicketAttachment> attachments;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Attachments', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (attachments.isEmpty)
              Text(
                'No attachments',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkTertiary,
                ),
              )
            else
              for (var i = 0; i < attachments.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.xs),
                _AttachmentRow(attachment: attachments[i]),
              ],
          ],
        ),
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.attachment});

  final TicketAttachment attachment;

  IconData get _icon => switch (attachment.kind) {
        'image' => Icons.image_outlined,
        'pdf' => Icons.picture_as_pdf_outlined,
        _ => Icons.insert_drive_file_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 18, color: AppColors.inkSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attachment.sizeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chronological activity ledger (row entries).
class _ActivityLedger extends StatelessWidget {
  const _ActivityLedger({required this.events});

  final List<TicketEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordered = [...events]..sort((a, b) => a.at.compareTo(b.at));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text('Timeline', style: theme.textTheme.titleMedium),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (ordered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'No activity recorded.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkTertiary,
                ),
              ),
            )
          else
            for (var i = 0; i < ordered.length; i++)
              _LedgerEntry(
                event: ordered[i],
                isLast: i == ordered.length - 1,
              ),
        ],
      ),
    );
  }
}

class _LedgerEntry extends StatelessWidget {
  const _LedgerEntry({required this.event, required this.isLast});

  final TicketEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = event.detail?.trim();
    final actor = event.actorName?.trim();

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border),
              ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatLedgerStamp(event.at),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.inkTertiary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            event.action,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actor != null && actor.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              actor,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.inkSecondary,
              ),
            ),
          ],
          if (detail != null && detail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
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
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.inkSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

String _formatTime(DateTime value) {
  final h = value.hour.toString().padLeft(2, '0');
  final m = value.minute.toString().padLeft(2, '0');
  return '${value.month}/${value.day} $h:$m';
}

String _formatLedgerStamp(DateTime value) {
  final y = value.year.toString();
  final mo = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  final h = value.hour.toString().padLeft(2, '0');
  final mi = value.minute.toString().padLeft(2, '0');
  final s = value.second.toString().padLeft(2, '0');
  return '$y-$mo-$d  $h:$mi:$s';
}
