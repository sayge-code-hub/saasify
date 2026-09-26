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
  static const currentVersion = '1.0.0';

  static final List<AppRelease> all = [
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
