import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_button.dart';
import 'package:saasify/core/widgets/app_empty_state.dart';
import 'package:saasify/core/widgets/app_page.dart';
import 'package:saasify/core/widgets/app_text.dart';
import 'package:saasify/core/widgets/app_text_field.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/domain/ticket_config.dart';
import 'package:saasify/features/ticketing/domain/ticket_sla.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_config_cubit.dart';
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

        return BlocBuilder<TicketConfigCubit, TicketConfig>(
          builder: (context, config) {
            final sla = TicketSla.evaluate(ticket: ticket, config: config);
            final mainColumn = _TicketMainColumn(
              ticket: ticket,
              replyController: _replyController,
              agentName: agentName,
              assignees: config.assignees,
              sla: sla,
            );
            final sideColumn = _TicketSideColumn(
              attachments: ticket.attachments,
              events: ticket.events,
            );

            return AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    ticket.id,
                    variant: AppTextVariant.meta,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    ticket.subject,
                    variant: AppTextVariant.pageTitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TicketChipCategories(
                    status: ticket.status,
                    priority: ticket.priority,
                    sla: sla,
                    tags: ticket.tags,
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
      },
    );
  }
}

/// Compact status / priority / SLA / tags strip in a single card.
class _TicketChipCategories extends StatelessWidget {
  const _TicketChipCategories({
    required this.status,
    required this.priority,
    required this.sla,
    required this.tags,
  });

  final TicketStatus status;
  final TicketPriority priority;
  final TicketSlaSnapshot sla;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs + 2,
        ),
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ChipCategory(
              label: 'Status',
              child: TicketStatusBadge(status: status),
            ),
            _ChipCategory(
              label: 'Priority',
              child: TicketPriorityBadge(priority: priority),
            ),
            _ChipCategory(
              label: 'SLA',
              child: _SlaChip(snapshot: sla),
            ),
            if (tags.isNotEmpty)
              _ChipCategory(
                label: 'Tags',
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final tag in tags)
                      TicketTagChip(
                        label: tag,
                        background: AppColors.surfaceMuted,
                        foreground: AppColors.inkSecondary,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChipCategory extends StatelessWidget {
  const _ChipCategory({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.inkTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            fontSize: 10,
            height: 1,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        child,
      ],
    );
  }
}

/// Left ~70%: details + comments.
class _TicketMainColumn extends StatelessWidget {
  const _TicketMainColumn({
    required this.ticket,
    required this.replyController,
    required this.agentName,
    required this.assignees,
    required this.sla,
  });

  final Ticket ticket;
  final TextEditingController replyController;
  final String agentName;
  final List<String> assignees;
  final TicketSlaSnapshot sla;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailsSection(ticket: ticket, assignees: assignees),
        const SizedBox(height: AppSpacing.lg),
        _SlaPanel(snapshot: sla),
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
  const _DetailsSection({
    required this.ticket,
    required this.assignees,
  });

  final Ticket ticket;
  final List<String> assignees;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TicketListCubit>();
    final currentAssignee = ticket.assigneeName?.isNotEmpty == true
        ? ticket.assigneeName
        : null;
    final assigneeOptions = <String>{
      ?currentAssignee,
      ...assignees,
    }.toList()
      ..sort();

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
            const AppText('Details', variant: AppTextVariant.sectionTitle),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 520;
                final rows = <Widget>[
                  _MetaRow(label: 'Customer', value: ticket.customerName),
                  _MetaRow(label: 'Email', value: ticket.customerEmail),
                  _AssigneeRow(
                    value: currentAssignee,
                    options: assigneeOptions,
                    onChanged: (value) => cubit.assign(ticket.id, value),
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
            const AppText(
              'Description',
              variant: AppTextVariant.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(ticket.description, variant: AppTextVariant.body),
          ],
        ),
      ),
    );
  }
}

class _AssigneeRow extends StatefulWidget {
  const _AssigneeRow({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  State<_AssigneeRow> createState() => _AssigneeRowState();
}

class _AssigneeRowState extends State<_AssigneeRow> {
  bool _editing = false;

  void _finishEditing([String? next]) {
    setState(() => _editing = false);
    if (next != widget.value) {
      widget.onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = widget.value?.isNotEmpty == true
        ? widget.value!
        : 'Unassigned';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assignee',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          if (_editing)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    key: const ValueKey('ticket-assignee'),
                    // ignore: deprecated_member_use
                    value: widget.value,
                    isExpanded: true,
                    autofocus: true,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Unassigned'),
                      ),
                      for (final name in widget.options)
                        DropdownMenuItem<String?>(
                          value: name,
                          child: Text(name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: _finishEditing,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                TextButton(
                  key: const ValueKey('ticket-assignee-cancel'),
                  onPressed: () => setState(() => _editing = false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.inkTertiary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            )
          else
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: AppColors.inkSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    displayName,
                    key: const ValueKey('ticket-assignee-display'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  key: const ValueKey('ticket-assignee-change'),
                  onPressed: () => setState(() => _editing = true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Change'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SlaPanel extends StatelessWidget {
  const _SlaPanel({required this.snapshot});

  final TicketSlaSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                const Expanded(
                  child: AppText(
                    'SLA',
                    variant: AppTextVariant.sectionTitle,
                  ),
                ),
                _SlaChip(snapshot: snapshot),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            const AppText(
              'Service Level Agreement — promised time to first agent reply '
              'and to resolve the case.',
              variant: AppTextVariant.sectionSubtitle,
            ),
            const SizedBox(height: AppSpacing.md),
            _SlaClockRow(clock: snapshot.firstResponse),
            const SizedBox(height: AppSpacing.sm),
            _SlaClockRow(clock: snapshot.resolution),
          ],
        ),
      ),
    );
  }
}

class _SlaClockRow extends StatelessWidget {
  const _SlaClockRow({required this.clock});

  final SlaClock clock;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String timing;
    if (clock.completedAt != null) {
      final delta = clock.completedAt!.difference(clock.dueAt);
      timing = delta.isNegative || delta == Duration.zero
          ? 'Completed ${TicketSla.formatDuration(clock.dueAt.difference(clock.completedAt!))} early'
          : 'Completed ${TicketSla.formatDuration(delta)} late';
    } else if (now.isAfter(clock.dueAt)) {
      timing =
          'Overdue by ${TicketSla.formatDuration(now.difference(clock.dueAt))}';
    } else {
      timing =
          '${TicketSla.formatDuration(clock.dueAt.difference(now))} remaining';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(clock.label, variant: AppTextVariant.label),
                  const SizedBox(height: 2),
                  AppText(
                    'Target ${TicketSla.formatDuration(clock.target)} · '
                    'Due ${_formatDate(clock.dueAt)}',
                    variant: AppTextVariant.sectionSubtitle,
                  ),
                  AppText(
                    timing,
                    variant: AppTextVariant.meta,
                  ),
                ],
              ),
            ),
            _SlaStatusBadge(status: clock.status),
          ],
        ),
      ),
    );
  }
}

class _SlaChip extends StatelessWidget {
  const _SlaChip({required this.snapshot});

  final TicketSlaSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final status = snapshot.anyBreached
        ? SlaClockStatus.breached
        : snapshot.anyAtRisk
            ? SlaClockStatus.atRisk
            : snapshot.firstResponse.status == SlaClockStatus.met &&
                    snapshot.resolution.status == SlaClockStatus.met
                ? SlaClockStatus.met
                : SlaClockStatus.onTrack;

    return _SlaStatusBadge(status: status, compact: true);
  }
}

class _SlaStatusBadge extends StatelessWidget {
  const _SlaStatusBadge({required this.status, this.compact = false});

  final SlaClockStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      SlaClockStatus.onTrack => (AppColors.successMuted, AppColors.success),
      SlaClockStatus.atRisk => (AppColors.warningMuted, AppColors.warning),
      SlaClockStatus.breached ||
      SlaClockStatus.metLate =>
        (AppColors.dangerMuted, AppColors.danger),
      SlaClockStatus.met => (AppColors.accentMuted, AppColors.accentDeep),
    };

    return TicketTagChip(
      label: status.label,
      background: bg,
      foreground: fg,
      fixedSize: compact,
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
            const AppText('Comments', variant: AppTextVariant.sectionTitle),
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
            const AppText(
              'Attachments',
              variant: AppTextVariant.sectionTitle,
            ),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: AppText(
              'Timeline',
              variant: AppTextVariant.sectionTitle,
            ),
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkSecondary,
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
