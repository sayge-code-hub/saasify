/// Spacing and radius scale. Use these instead of magic numbers.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  /// Standard content measure for admin pages via [AppPage].
  /// Keep screens on this width — do not invent narrower per-page max widths
  /// unless a focused form truly needs a tighter column.
  static const double contentMaxWidth = 1280;
  static const double pagePaddingCompact = md;
  static const double pagePaddingExpanded = xl;

  /// Breakpoint for two-up section grids (Config, etc.).
  static const double sectionGridMinWidth = 720;
}
