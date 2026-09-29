/// A single release / deployment note for the public changelog.
enum ReleaseChangeType { feature, improvement, bugfix }

class ReleaseChange {
  const ReleaseChange({
    required this.type,
    required this.summary,
  });

  final ReleaseChangeType type;
  final String summary;

  String get typeLabel => switch (type) {
        ReleaseChangeType.feature => 'Feature',
        ReleaseChangeType.improvement => 'Improvement',
        ReleaseChangeType.bugfix => 'Bug fix',
      };
}

class AppRelease {
  const AppRelease({
    required this.version,
    required this.releasedAt,
    required this.title,
    required this.changes,
  });

  final String version;
  final DateTime releasedAt;
  final String title;
  final List<ReleaseChange> changes;
}

/// Mock deployment history for the Release History screen.
abstract final class ReleaseNotes {
  static const currentVersion = '1.1.5';

  static final List<AppRelease> all = [
    AppRelease(
      version: '1.1.5',
      releasedAt: DateTime.utc(2026, 9, 29),
      title: 'Production deploy',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary: 'Automated release 1.1.5 published to production.',
        ),
      ],
    ),
    AppRelease(
      version: '1.1.4',
      releasedAt: DateTime.utc(2026, 9, 29),
      title: 'Production deploy',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary: 'Automated release 1.1.4 published to production.',
        ),
      ],
    ),
    AppRelease(
      version: '1.1.3',
      releasedAt: DateTime.utc(2026, 9, 29),
      title: 'Production deploy',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary: 'Automated release 1.1.3 published to production.',
        ),
      ],
    ),
    AppRelease(
      version: '1.1.2',
      releasedAt: DateTime(2026, 9, 26),
      title: 'List and detail chrome cleanup',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'All Tickets Export opens a centered dialog with Excel, PDF, and Raw JSON options.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'Ticket titles and Export / Email / Filter / Sort actions use regular weight; list and detail tops are more spacious.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'Detail chips share one size and are grouped by Status, Priority, SLA, and Tags.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'Sidebar Ticketing nav keeps Dashboard, Add Ticket, All Tickets, and Config only.',
        ),
      ],
    ),
    AppRelease(
      version: '1.1.1',
      releasedAt: DateTime(2026, 9, 26),
      title: 'Config editor polish',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'Config hub uses searchable section cards with Edit screens instead of inline chip adders.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'Option list editors confirm adds, warn on discard, and keep the top bar free of a Config title.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary: 'App text is selectable so labels and values can be copied.',
        ),
      ],
    ),
    AppRelease(
      version: '1.1.0',
      releasedAt: DateTime(2026, 9, 26),
      title: 'Assignee, config dropdowns, and SLA',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary:
              'Change assignee on ticket detail from the configured agent list.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary:
              'Config page edits Application, Priority, Bug, Distribution List, and Assignee dropdown options used by Add Ticket.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary:
              'SLA clocks for first response and resolution by priority, with On track / At risk / Breached / Met status on detail.',
        ),
      ],
    ),
    AppRelease(
      version: '1.0.0',
      releasedAt: DateTime(2026, 9, 26),
      title: 'Ticketing admin polish',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary:
              'Add Ticket form with Header, Application, Priority, Bug, Responsibility, Affected Equipment, Description, and Distribution List.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary:
              'Ticket detail 70/30 layout with Details + Comments, Attachments, and Timeline ledger.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'Top bar back control for ticket detail; removed in-page workflow card.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'Unified light-grey page background across dashboard, lists, and detail.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.bugfix,
          summary:
              'Detail field labels made darker so Customer, Email, and Assignee stay readable.',
        ),
      ],
    ),
    AppRelease(
      version: '0.9.2',
      releasedAt: DateTime(2026, 9, 24),
      title: 'Ticket list & selection',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary:
              'All Tickets search, export actions, multi-select, and bulk delete.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary:
              'Underline-style sidebar active state and tighter list row alignment.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.bugfix,
          summary: 'Sticky Create Ticket CTAs stay full-width on wide layouts.',
        ),
      ],
    ),
    AppRelease(
      version: '0.9.0',
      releasedAt: DateTime(2026, 9, 22),
      title: 'Ticketing module shell',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary:
              'Ticketing nav with Dashboard, Add Ticket, status queues, Priority, and Config.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary: 'Dashboard analytics for ticket status and priority.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary: 'Soft coral · black · white Maglo-inspired visual system.',
        ),
      ],
    ),
    AppRelease(
      version: '0.8.0',
      releasedAt: DateTime(2026, 9, 18),
      title: 'Auth & workspace foundation',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary: 'Mock email/password login gate with in-memory session.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.feature,
          summary: 'Responsive shell with collapsible module sidebar.',
        ),
        ReleaseChange(
          type: ReleaseChangeType.bugfix,
          summary: 'SPA path routes served correctly for hard refresh on web.',
        ),
      ],
    ),
  ];
}
