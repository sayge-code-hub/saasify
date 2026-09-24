import 'package:flutter/widgets.dart';

/// Layout buckets for responsive UI.
enum Breakpoint { compact, medium, expanded }

/// Width thresholds — see `specs/responsive.md`.
abstract final class AppBreakpoints {
  static const double medium = 600;
  static const double expanded = 1024;

  static Breakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return fromWidth(width);
  }

  static Breakpoint fromWidth(double width) {
    if (width >= expanded) return Breakpoint.expanded;
    if (width >= medium) return Breakpoint.medium;
    return Breakpoint.compact;
  }
}

extension BreakpointContextX on BuildContext {
  Breakpoint get breakpoint => AppBreakpoints.of(this);

  bool get isCompact => breakpoint == Breakpoint.compact;

  bool get isMedium => breakpoint == Breakpoint.medium;

  bool get isExpanded => breakpoint == Breakpoint.expanded;
}
