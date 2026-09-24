import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_logo.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';
import 'package:saasify/features/ticketing/presentation/widgets/ticket_badges.dart';

/// Maglo-inspired dashboard: main workspace column + right attention panel.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  static const double _rightPanelWidth = 300;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        final open = state.countWhere((t) => t.status == TicketStatus.open);
        final pending =
            state.countWhere((t) => t.status == TicketStatus.pending);
        final inProgress =
            state.countWhere((t) => t.status == TicketStatus.inProgress);
        final resolved =
            state.countWhere((t) => t.status == TicketStatus.resolved);
        final active = state.tickets
            .where(
              (t) =>
                  t.status != TicketStatus.closed &&
                  t.status != TicketStatus.resolved,
            )
            .toList();
        final urgent = active
            .where((t) => t.priority == TicketPriority.urgent)
            .toList();
        final spotlight = urgent.isNotEmpty
            ? urgent.first
            : (active.isNotEmpty ? active.first : null);
        final recent = active.take(5).toList();

        final showSide = !context.isCompact;

        final main = _OverviewMain(
          open: open,
          pending: pending,
          inProgress: inProgress,
          resolved: resolved,
          recent: recent,
        );

        final side = _OverviewSidePanel(
          spotlight: spotlight,
          urgentCount: urgent.length,
          openCount: open,
        );

        if (!showSide) {
          return ColoredBox(
            color: AppColors.canvas,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  main,
                  const SizedBox(height: AppSpacing.lg),
                  side,
                ],
              ),
            ),
          );
        }

        return ColoredBox(
          color: AppColors.canvas,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: main,
                ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: _rightPanelWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: side,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewMain extends StatelessWidget {
  const _OverviewMain({
    required this.open,
    required this.pending,
    required this.inProgress,
    required this.resolved,
    required this.recent,
  });

  final int open;
  final int pending;
  final int inProgress;
  final int resolved;
  final List<Ticket> recent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _WorkspaceBanner(),
        const SizedBox(height: AppSpacing.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetaBlock(
                title: 'Workspace pulse',
                children: [
                  _MetaLine(label: 'Open', value: '$open'),
                  _MetaLine(label: 'In progress', value: '$inProgress'),
                  _MetaLine(label: 'Pending', value: '$pending'),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: _MetaBlock(
                title: 'Resolved this week',
                children: [
                  _MetaLine(label: 'Closed out', value: '$resolved'),
                  const _MetaLine(
                    label: 'Queue health',
                    value: 'On track',
                  ),
                  const _MetaLine(
                    label: 'SLA focus',
                    value: 'Urgent first',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Active tickets',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _TicketTable(tickets: recent),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.go('/ticketing'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'View all tickets',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Column(
              children: [
                _SummaryRow(label: 'Open', value: '$open'),
                _SummaryRow(label: 'In progress', value: '$inProgress'),
                _SummaryRow(label: 'Pending', value: '$pending'),
                const Divider(height: AppSpacing.lg),
                _SummaryRow(
                  label: 'Active total',
                  value: '${open + inProgress + pending}',
                  emphasize: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceBanner extends StatelessWidget {
  const _WorkspaceBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              child: AppLogoWordmark(height: 28),
            ),
            const Spacer(),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'ops@saasify.io',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    'Support workspace · Admin',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.right,
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

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.inkTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _TicketTable extends StatelessWidget {
  const _TicketTable({required this.tickets});

  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tickets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          'No active tickets right now.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.inkSecondary,
          ),
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(flex: 4, child: _ColHead('TICKET')),
              Expanded(flex: 2, child: _ColHead('STATUS')),
              Expanded(flex: 2, child: _ColHead('PRIORITY')),
              Expanded(flex: 2, child: _ColHead('CUSTOMER')),
            ],
          ),
        ),
        for (final ticket in tickets) ...[
          const SizedBox(height: AppSpacing.xs),
          Material(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: () => context.go('/ticketing/tickets/${ticket.id}'),
              mouseCursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            ticket.id,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.inkTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TicketStatusBadge(status: ticket.status),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TicketPriorityBadge(priority: ticket.priority),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        ticket.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ColHead extends StatelessWidget {
  const _ColHead(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.inkTertiary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasize
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          )
        : theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _OverviewSidePanel extends StatelessWidget {
  const _OverviewSidePanel({
    required this.spotlight,
    required this.urgentCount,
    required this.openCount,
  });

  final Ticket? spotlight;
  final int urgentCount;
  final int openCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Needs attention',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            IconButton(
              tooltip: 'More',
              onPressed: () {},
              icon: const Icon(Icons.more_horiz, color: AppColors.inkTertiary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (spotlight == null)
          Text(
            'Queue is clear.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkSecondary,
            ),
          )
        else
          _SpotlightCard(ticket: spotlight!),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.go('/ticketing'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentMuted,
              foregroundColor: AppColors.accentHover,
              elevation: 0,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: const Text('Browse queue'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Quick actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _InfoField(
          label: 'Open queue',
          value: '$openCount tickets waiting',
          icon: Icons.inbox_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        _InfoField(
          label: 'Urgent',
          value: urgentCount == 0
              ? 'None active'
              : '$urgentCount need triage',
          icon: Icons.priority_high,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () => context.go('/ticketing'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.ink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              textStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            child: const Text('Open ticketing'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: spotlight == null
                    ? null
                    : () => context.go(
                          '/ticketing/tickets/${spotlight!.id}',
                        ),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/ticketing/open'),
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => context.go('/ticketing/tickets/${ticket.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.accentMuted,
                foregroundColor: AppColors.accent,
                child: Text(
                  ticket.customerName.isNotEmpty
                      ? ticket.customerName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.customerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticket.customerEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.inkTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ticket.id,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.inkSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.inkTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: AppColors.inkTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
