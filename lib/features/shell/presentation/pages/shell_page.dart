import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/constants/app_constants.dart';
import 'package:saasify/core/responsive/app_breakpoints.dart';
import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/core/widgets/app_scaffold.dart';
import 'package:saasify/features/shell/presentation/bloc/shell_cubit.dart';

/// Adaptive chrome: bottom bar on compact, rail on medium/expanded.
class ShellPage extends StatelessWidget {
  const ShellPage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellCubit, ShellState>(
      builder: (context, state) {
        final isCompact = context.isCompact;
        return AppScaffold(
          appBar: AppBar(
            title: Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1),
            ),
          ),
          body: Row(
            children: [
              if (!isCompact) ...[
                _ShellRail(selectedIndex: state.selectedIndex),
                const VerticalDivider(width: 1),
              ],
              Expanded(child: child),
            ],
          ),
          bottomNavigationBar: isCompact
              ? NavigationBar(
                  selectedIndex: state.selectedIndex,
                  onDestinationSelected: (index) =>
                      _onSelect(context, index),
                  destinations: [
                    for (final destination in ShellDestinations.all)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: destination.label,
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }

  void _onSelect(BuildContext context, int index) {
    context.read<ShellCubit>().selectIndex(index);
    context.go(ShellDestinations.all[index].location);
  }
}

class _ShellRail extends StatelessWidget {
  const _ShellRail({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final extended = context.isExpanded;
    return NavigationRail(
      selectedIndex: selectedIndex,
      extended: extended,
      minExtendedWidth: 200,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: CircleAvatar(
          backgroundColor: AppColors.accentMuted,
          foregroundColor: AppColors.accent,
          child: Text(
            'S',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
      onDestinationSelected: (index) {
        context.read<ShellCubit>().selectIndex(index);
        context.go(ShellDestinations.all[index].location);
      },
      destinations: [
        for (final destination in ShellDestinations.all)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
