import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/presentation/bloc/ticket_list_cubit.dart';

/// Analytics-style overview: status and priority breakdowns.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        final tickets = state.tickets;
        final statusSlices = _statusSlices(tickets);
        final prioritySlices = _prioritySlices(tickets);
        final compact = context.isCompact;

        return ColoredBox(
          color: AppColors.canvas,
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async {
              // Mock catalog is in-memory; pull-to-refresh is a visual affordance.
              await Future<void>.delayed(const Duration(milliseconds: 350));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                compact ? AppSpacing.md : AppSpacing.xl,
                AppSpacing.md,
                compact ? AppSpacing.md : AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PageToolbar(),
                  const SizedBox(height: AppSpacing.md),
                  if (compact) ...[
                    _BreakdownCard(
                      title: 'Ticket by status',
                      totalLabel: 'Total',
                      slices: statusSlices,
                      visualization: _BreakdownViz.donut,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _BreakdownCard(
                      title: 'Ticket by priority',
                      totalLabel: 'Total',
                      slices: prioritySlices,
                      visualization: _BreakdownViz.bars,
                    ),
                  ] else
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _BreakdownCard(
                              title: 'Ticket by status',
                              totalLabel: 'Total',
                              slices: statusSlices,
                              visualization: _BreakdownViz.donut,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _BreakdownCard(
                              title: 'Ticket by priority',
                              totalLabel: 'Total',
                              slices: prioritySlices,
                              visualization: _BreakdownViz.bars,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _BreakdownViz { donut, bars }

class _Slice {
  const _Slice({
    required this.label,
    required this.count,
    required this.color,
    this.route,
  });

  final String label;
  final int count;
  final Color color;
  final String? route;
}

List<_Slice> _statusSlices(List<Ticket> tickets) {
  int count(TicketStatus s) => tickets.where((t) => t.status == s).length;
  return [
    _Slice(
      label: 'Open',
      count: count(TicketStatus.open),
      color: AppColors.accent,
      route: '/ticketing/open',
    ),
    _Slice(
      label: 'In progress',
      count: count(TicketStatus.inProgress),
      color: AppColors.ink,
      route: '/ticketing',
    ),
    _Slice(
      label: 'Pending',
      count: count(TicketStatus.pending),
      color: AppColors.accentLight,
      route: '/ticketing/pending',
    ),
    _Slice(
      label: 'Resolved',
      count: count(TicketStatus.resolved),
      color: AppColors.inkTertiary,
      route: '/ticketing/resolved',
    ),
    _Slice(
      label: 'Closed',
      count: count(TicketStatus.closed),
      color: AppColors.border,
      route: '/ticketing',
    ),
  ].where((s) => s.count > 0).toList();
}

List<_Slice> _prioritySlices(List<Ticket> tickets) {
  int count(TicketPriority p) => tickets.where((t) => t.priority == p).length;
  return [
    _Slice(
      label: 'Urgent',
      count: count(TicketPriority.urgent),
      color: AppColors.ink,
    ),
    _Slice(
      label: 'High',
      count: count(TicketPriority.high),
      color: AppColors.accent,
    ),
    _Slice(
      label: 'Medium',
      count: count(TicketPriority.medium),
      color: AppColors.accentLight,
    ),
    _Slice(
      label: 'Low',
      count: count(TicketPriority.low),
      color: AppColors.inkTertiary,
    ),
  ].where((s) => s.count > 0).toList();
}

class _PageToolbar extends StatelessWidget {
  const _PageToolbar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final stamp =
        '${now.day}.${now.month}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ticket system',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stamp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkTertiary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dashboard refreshed.')),
            );
          },
          icon: const Icon(Icons.refresh, color: AppColors.inkSecondary),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.title,
    required this.totalLabel,
    required this.slices,
    required this.visualization,
  });

  final String title;
  final String totalLabel;
  final List<_Slice> slices;
  final _BreakdownViz visualization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = slices.fold<int>(0, (sum, s) => sum + s.count);

    return _DashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.refresh,
                    size: 20,
                    color: AppColors.inkTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(
                  'No tickets yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
              )
            else if (visualization == _BreakdownViz.donut)
              _DonutBreakdown(slices: slices, total: total, totalLabel: totalLabel)
            else
              _BarBreakdown(slices: slices, total: total),
          ],
        ),
      ),
    );
  }
}

class _DonutBreakdown extends StatelessWidget {
  const _DonutBreakdown({
    required this.slices,
    required this.total,
    required this.totalLabel,
  });

  final List<_Slice> slices;
  final int total;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              for (final slice in slices)
                _LegendRow(
                  slice: slice,
                  total: total,
                  onTap: slice.route == null
                      ? null
                      : () => context.go(slice.route!),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 148,
          height: 148,
          child: CustomPaint(
            painter: _DonutPainter(slices: slices, total: total),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      height: 1,
                    ),
                  ),
                  Text(
                    totalLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.inkTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BarBreakdown extends StatelessWidget {
  const _BarBreakdown({required this.slices, required this.total});

  final List<_Slice> slices;
  final int total;

  @override
  Widget build(BuildContext context) {
    final maxCount = slices.map((s) => s.count).fold<int>(0, math.max);

    return Column(
      children: [
        for (final slice in slices) ...[
          _PriorityBarRow(slice: slice, maxCount: maxCount, total: total),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.total,
    this.onTap,
  });

  final _Slice slice;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = total == 0 ? 0 : ((slice.count / total) * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: slice.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                slice.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${slice.count}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            SizedBox(
              width: 40,
              child: Text(
                '$pct%',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBarRow extends StatelessWidget {
  const _PriorityBarRow({
    required this.slice,
    required this.maxCount,
    required this.total,
  });

  final _Slice slice;
  final int maxCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = total == 0 ? 0.0 : slice.count / total;
    final barFrac = maxCount == 0 ? 0.0 : slice.count / maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                slice.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${slice.count}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${(pct * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.surfaceMuted),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: barFrac.clamp(0.0, 1.0),
                    heightFactor: 1,
                    child: ColoredBox(color: slice.color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.total});

  final List<_Slice> slices;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.34;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final track = Paint()
      ..color = AppColors.surfaceMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (total <= 0) return;

    var start = -math.pi / 2;
    final gap = slices.length > 1 ? 0.04 : 0.0;
    for (final slice in slices) {
      final sweep = (slice.count / total) * math.pi * 2;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      final usable = math.max(0.0, sweep - gap);
      canvas.drawArc(rect, start + gap / 2, usable, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.slices != slices;
  }
}
