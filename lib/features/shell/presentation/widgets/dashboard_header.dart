import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saasify/core/theme/app_colors.dart';
import 'package:saasify/core/theme/app_spacing.dart';
import 'package:saasify/features/auth/presentation/bloc/auth_cubit.dart';

/// Maglo-style top chrome inside the main column (title left, actions right).
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.title,
    this.leading,
    this.userName,
    this.showMenu = false,
    this.onMenu,
    super.key,
  });

  final String title;

  /// Optional leading content (e.g. back + “All tickets”) instead of [title].
  final Widget? leading;
  final String? userName;
  final bool showMenu;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = GoRouterState.of(context).uri.path;
    final onSettings = path == '/settings';

    return Material(
      color: AppColors.surface,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              if (showMenu)
                IconButton(
                  tooltip: 'Menu',
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu),
                ),
              Expanded(
                child: leading ??
                    (title.isEmpty
                        ? const SizedBox.shrink()
                        : Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.ink,
                ),
              ),
              IconButton(
                key: const ValueKey('header-help'),
                tooltip: 'Help',
                onPressed: () => context.go('/help'),
                icon: const Icon(
                  Icons.help_outline,
                  color: AppColors.ink,
                ),
              ),
              IconButton(
                key: const ValueKey('header-settings'),
                tooltip: 'Settings',
                onPressed: () => context.go('/settings'),
                icon: Icon(
                  onSettings ? Icons.settings : Icons.settings_outlined,
                  color: onSettings ? AppColors.accent : AppColors.ink,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PopupMenuButton<_ProfileMenuAction>(
                key: const ValueKey('header-profile-menu'),
                tooltip: 'Account',
                offset: const Offset(0, 48),
                onSelected: (action) {
                  switch (action) {
                    case _ProfileMenuAction.profile:
                      context.go('/profile');
                    case _ProfileMenuAction.logout:
                      context.read<AuthCubit>().logout();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ProfileMenuAction.profile,
                    child: Text('Profile'),
                  ),
                  PopupMenuItem(
                    value: _ProfileMenuAction.logout,
                    child: Text('Logout'),
                  ),
                ],
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.accentMuted,
                      foregroundColor: AppColors.accentHover,
                      child: Text(
                        (userName != null && userName!.isNotEmpty)
                            ? userName![0].toUpperCase()
                            : 'A',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.accentHover,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (userName != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        userName!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.ink,
                      ),
                    ],
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

enum _ProfileMenuAction { profile, logout }

/// Live local date, time, and timezone for the shell header on every route.
class HeaderDateTime extends StatefulWidget {
  const HeaderDateTime({super.key, this.now});

  /// Optional clock override for tests.
  final DateTime Function()? now;

  @override
  State<HeaderDateTime> createState() => _HeaderDateTimeState();
}

class _HeaderDateTimeState extends State<HeaderDateTime> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = (widget.now ?? DateTime.now)();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _now = (widget.now ?? DateTime.now)());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        key: const ValueKey('header-datetime'),
        formatHeaderDateTime(_now),
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.inkTertiary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Formats e.g. `Sat, 26 Sep 2026`.
String formatHeaderDate(DateTime dateTime) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final weekday = weekdays[dateTime.weekday - 1];
  final month = months[dateTime.month - 1];
  return '$weekday, ${dateTime.day} $month ${dateTime.year}';
}

/// Formats e.g. `19:02 UTC+00:00`.
String formatHeaderTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final tz = formatTimezoneLabel(dateTime);
  return '$hour:$minute $tz';
}

/// Formats e.g. `Sat, 26 Sep 2026  ·  19:02 UTC+00:00`.
String formatHeaderDateTime(DateTime dateTime) {
  return '${formatHeaderDate(dateTime)}  ·  ${formatHeaderTime(dateTime)}';
}

String formatTimezoneLabel(DateTime dateTime) {
  final name = dateTime.timeZoneName.trim();
  if (RegExp(r'^[A-Za-z]{2,5}$').hasMatch(name)) {
    return name.toUpperCase();
  }
  final offset = dateTime.timeZoneOffset;
  final totalMinutes = offset.inMinutes;
  final sign = totalMinutes < 0 ? '-' : '+';
  final abs = totalMinutes.abs();
  final hours = (abs ~/ 60).toString().padLeft(2, '0');
  final minutes = (abs % 60).toString().padLeft(2, '0');
  return 'UTC$sign$hours:$minutes';
}
