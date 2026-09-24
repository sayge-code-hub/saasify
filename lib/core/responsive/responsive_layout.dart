import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

/// Picks a child based on the current [Breakpoint].
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.compact,
    this.medium,
    this.expanded,
    super.key,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return switch (context.breakpoint) {
      Breakpoint.expanded => expanded ?? medium ?? compact,
      Breakpoint.medium => medium ?? compact,
      Breakpoint.compact => compact,
    };
  }
}
