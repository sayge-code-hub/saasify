import 'package:saasify/features/ticketing/domain/ticket.dart';

/// Seed catalog for admin UI demos. Mutated only in memory via cubits.
abstract final class MockTickets {
  static final DateTime _now = DateTime(2026, 9, 24, 10);

  static List<Ticket> createCatalog() {
    return [
      _ticket(
        id: 'TCK-1042',
        subject: 'Cannot reset password from mobile app',
        description:
            'Customer taps “Forgot password” and never receives the email.',
        status: TicketStatus.open,
        priority: TicketPriority.high,
        customerName: 'Maya Chen',
        customerEmail: 'maya.chen@northwind.io',
        createdAt: _now.subtract(const Duration(hours: 5)),
        updatedAt: _now.subtract(const Duration(minutes: 40)),
        tags: const ['auth', 'mobile'],
        messages: [
          TicketMessage(
            id: 'm1',
            authorName: 'Maya Chen',
            isAgent: false,
            createdAt: _now.subtract(const Duration(hours: 5)),
            body:
                'I tried twice yesterday. Still no reset email in inbox or spam.',
          ),
        ],
      ),
      _ticket(
        id: 'TCK-1038',
        subject: 'Invoice PDF downloads corrupted',
        description: 'Billing page PDF opens as blank for invoices after Aug.',
        status: TicketStatus.inProgress,
        priority: TicketPriority.urgent,
        customerName: 'Jordan Lee',
        customerEmail: 'jordan@brightline.co',
        assigneeName: 'Alex Rivera',
        createdAt: _now.subtract(const Duration(days: 1, hours: 3)),
        updatedAt: _now.subtract(const Duration(minutes: 15)),
        tags: const ['billing'],
        messages: [
          TicketMessage(
            id: 'm2',
            authorName: 'Jordan Lee',
            isAgent: false,
            createdAt: _now.subtract(const Duration(days: 1, hours: 3)),
            body: 'All August invoices fail. July ones are fine.',
          ),
          TicketMessage(
            id: 'm3',
            authorName: 'Alex Rivera',
            isAgent: true,
            createdAt: _now.subtract(const Duration(hours: 2)),
            body:
                'Reproduced on staging. Checking the PDF service change from Monday.',
          ),
        ],
        extraEvents: [
          TicketEvent(
            id: 'e-1038-assign',
            action: 'Assigned',
            detail: 'Assigned to Alex Rivera',
            actorName: 'System',
            at: _now.subtract(const Duration(days: 1, hours: 2)),
          ),
          TicketEvent(
            id: 'e-1038-status',
            action: 'Status changed',
            detail: 'Open → In progress',
            actorName: 'Alex Rivera',
            at: _now.subtract(const Duration(hours: 3)),
          ),
        ],
        attachments: const [
          TicketAttachment(
            id: 'a1',
            name: 'blank-invoice-aug.pdf',
            sizeLabel: '248 KB',
            kind: 'pdf',
          ),
          TicketAttachment(
            id: 'a2',
            name: 'billing-screenshot.png',
            sizeLabel: '1.1 MB',
            kind: 'image',
          ),
        ],
      ),
      _ticket(
        id: 'TCK-1031',
        subject: 'SSO login loop with Okta',
        description: 'Enterprise SSO redirects bounce between IdP and app.',
        status: TicketStatus.pending,
        priority: TicketPriority.high,
        customerName: 'Priya Nair',
        customerEmail: 'priya.nair@helix.health',
        assigneeName: 'Sam Ortiz',
        createdAt: _now.subtract(const Duration(days: 2)),
        updatedAt: _now.subtract(const Duration(hours: 6)),
        tags: const ['sso', 'enterprise'],
        messages: [
          TicketMessage(
            id: 'm4',
            authorName: 'Priya Nair',
            isAgent: false,
            createdAt: _now.subtract(const Duration(days: 2)),
            body: 'Started after we rotated Okta certificates.',
          ),
          TicketMessage(
            id: 'm5',
            authorName: 'Sam Ortiz',
            isAgent: true,
            createdAt: _now.subtract(const Duration(hours: 8)),
            body:
                'Waiting on updated metadata XML from your IT team to finish.',
          ),
        ],
        extraEvents: [
          TicketEvent(
            id: 'e-1031-assign',
            action: 'Assigned',
            detail: 'Assigned to Sam Ortiz',
            actorName: 'System',
            at: _now.subtract(const Duration(days: 1, hours: 20)),
          ),
          TicketEvent(
            id: 'e-1031-status',
            action: 'Status changed',
            detail: 'In progress → Pending',
            actorName: 'Sam Ortiz',
            at: _now.subtract(const Duration(hours: 8)),
          ),
        ],
        attachments: const [
          TicketAttachment(
            id: 'a3',
            name: 'okta-metadata.xml',
            sizeLabel: '12 KB',
            kind: 'file',
          ),
        ],
      ),
      _ticket(
        id: 'TCK-1024',
        subject: 'Webhook deliveries delayed ~20 minutes',
        description: 'Outbound webhooks queue longer than SLA.',
        status: TicketStatus.open,
        priority: TicketPriority.medium,
        customerName: 'Chris Park',
        customerEmail: 'chris@orbit.dev',
        assigneeName: 'Alex Rivera',
        createdAt: _now.subtract(const Duration(hours: 12)),
        updatedAt: _now.subtract(const Duration(hours: 1)),
        tags: const ['api'],
        messages: [
          TicketMessage(
            id: 'm6',
            authorName: 'Chris Park',
            isAgent: false,
            createdAt: _now.subtract(const Duration(hours: 12)),
            body: 'Seeing consistent lag since Tuesday deploy window.',
          ),
        ],
        extraEvents: [
          TicketEvent(
            id: 'e-1024-assign',
            action: 'Assigned',
            detail: 'Assigned to Alex Rivera',
            actorName: 'System',
            at: _now.subtract(const Duration(hours: 10)),
          ),
        ],
      ),
      _ticket(
        id: 'TCK-1019',
        subject: 'Seat invite emails branded incorrectly',
        description: 'Invite template still shows previous workspace name.',
        status: TicketStatus.resolved,
        priority: TicketPriority.low,
        customerName: 'Elena Rossi',
        customerEmail: 'elena@campo.studio',
        assigneeName: 'Jamie Fox',
        createdAt: _now.subtract(const Duration(days: 4)),
        updatedAt: _now.subtract(const Duration(days: 1)),
        tags: const ['email'],
        messages: [
          TicketMessage(
            id: 'm7',
            authorName: 'Elena Rossi',
            isAgent: false,
            createdAt: _now.subtract(const Duration(days: 4)),
            body: 'New invites say “Campo Draft” instead of “Campo Studio”.',
          ),
          TicketMessage(
            id: 'm8',
            authorName: 'Jamie Fox',
            isAgent: true,
            createdAt: _now.subtract(const Duration(days: 1, hours: 2)),
            body: 'Cache purged and template republished. Please re-test.',
          ),
        ],
        extraEvents: [
          TicketEvent(
            id: 'e-1019-status',
            action: 'Status changed',
            detail: 'Pending → Resolved',
            actorName: 'Jamie Fox',
            at: _now.subtract(const Duration(days: 1)),
          ),
        ],
      ),
      _ticket(
        id: 'TCK-1012',
        subject: 'CSV export truncates Unicode names',
        description: 'Exported members CSV mangles accented characters.',
        status: TicketStatus.inProgress,
        priority: TicketPriority.medium,
        customerName: 'Noah Berg',
        customerEmail: 'noah@fjord.app',
        assigneeName: 'Jamie Fox',
        createdAt: _now.subtract(const Duration(days: 3)),
        updatedAt: _now.subtract(const Duration(hours: 3)),
        tags: const ['export'],
        messages: [
          TicketMessage(
            id: 'm9',
            authorName: 'Noah Berg',
            isAgent: false,
            createdAt: _now.subtract(const Duration(days: 3)),
            body: 'Example: “José” becomes “JosÃ©” in Excel.',
          ),
        ],
        attachments: const [
          TicketAttachment(
            id: 'a4',
            name: 'members-export.csv',
            sizeLabel: '86 KB',
            kind: 'file',
          ),
        ],
      ),
      _ticket(
        id: 'TCK-1007',
        subject: 'Dark mode contrast on billing table',
        description: 'Secondary text fails WCAG on dark theme billing page.',
        status: TicketStatus.closed,
        priority: TicketPriority.low,
        customerName: 'Ava Brooks',
        customerEmail: 'ava@pixelcraft.com',
        assigneeName: 'Sam Ortiz',
        createdAt: _now.subtract(const Duration(days: 10)),
        updatedAt: _now.subtract(const Duration(days: 6)),
        tags: const ['a11y', 'ui'],
        messages: [
          TicketMessage(
            id: 'm10',
            authorName: 'Ava Brooks',
            isAgent: false,
            createdAt: _now.subtract(const Duration(days: 10)),
            body: 'Hard to read amounts in dark mode on Safari.',
          ),
          TicketMessage(
            id: 'm11',
            authorName: 'Sam Ortiz',
            isAgent: true,
            createdAt: _now.subtract(const Duration(days: 7)),
            body: 'Contrast tokens updated in 2.14. Closing after confirm.',
          ),
        ],
        extraEvents: [
          TicketEvent(
            id: 'e-1007-resolved',
            action: 'Status changed',
            detail: 'In progress → Resolved',
            actorName: 'Sam Ortiz',
            at: _now.subtract(const Duration(days: 7)),
          ),
          TicketEvent(
            id: 'e-1007-closed',
            action: 'Status changed',
            detail: 'Resolved → Closed',
            actorName: 'Sam Ortiz',
            at: _now.subtract(const Duration(days: 6)),
          ),
        ],
      ),
      _ticket(
        id: 'TCK-1001',
        subject: 'API rate limit headers missing on 429',
        description: 'Clients cannot back off correctly without Retry-After.',
        status: TicketStatus.open,
        priority: TicketPriority.urgent,
        customerName: 'Diego Alvarez',
        customerEmail: 'diego@stackhaus.io',
        createdAt: _now.subtract(const Duration(hours: 2)),
        updatedAt: _now.subtract(const Duration(minutes: 25)),
        tags: const ['api', 'platform'],
        messages: [
          TicketMessage(
            id: 'm12',
            authorName: 'Diego Alvarez',
            isAgent: false,
            createdAt: _now.subtract(const Duration(hours: 2)),
            body:
                'Hitting 429s during batch sync. No Retry-After or remaining headers.',
          ),
        ],
      ),
      _ticket(
        id: 'TCK-0994',
        subject: 'Notification digests arriving twice',
        description: 'Daily digest email sent in duplicate for two seats.',
        status: TicketStatus.pending,
        priority: TicketPriority.medium,
        customerName: 'Hannah Kim',
        customerEmail: 'hannah@lumen.co',
        assigneeName: 'Alex Rivera',
        createdAt: _now.subtract(const Duration(days: 1, hours: 8)),
        updatedAt: _now.subtract(const Duration(hours: 4)),
        tags: const ['email'],
        messages: [
          TicketMessage(
            id: 'm13',
            authorName: 'Hannah Kim',
            isAgent: false,
            createdAt: _now.subtract(const Duration(days: 1, hours: 8)),
            body: 'Both digests are identical and 2 minutes apart.',
          ),
        ],
      ),
      _ticket(
        id: 'TCK-0988',
        subject: 'Workspace rename not reflected in audit log',
        description: 'Audit trail still shows previous workspace display name.',
        status: TicketStatus.resolved,
        priority: TicketPriority.low,
        customerName: 'Omar Haddad',
        customerEmail: 'omar@cedar.systems',
        assigneeName: 'Jamie Fox',
        createdAt: _now.subtract(const Duration(days: 5)),
        updatedAt: _now.subtract(const Duration(days: 2)),
        tags: const ['audit'],
        messages: [
          TicketMessage(
            id: 'm14',
            authorName: 'Omar Haddad',
            isAgent: false,
            createdAt: _now.subtract(const Duration(days: 5)),
            body: 'Renamed last week; audit events still say Cedar Ops.',
          ),
        ],
      ),
    ];
  }

  static Ticket _ticket({
    required String id,
    required String subject,
    required String description,
    required TicketStatus status,
    required TicketPriority priority,
    required String customerName,
    required String customerEmail,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<TicketMessage> messages,
    String? assigneeName,
    List<String> tags = const [],
    List<TicketEvent> extraEvents = const [],
    List<TicketAttachment> attachments = const [],
  }) {
    final events = <TicketEvent>[
      TicketEvent(
        id: '$id-created',
        action: 'Ticket created',
        detail: 'Case opened · ${priority.label} priority',
        actorName: customerName,
        at: createdAt,
      ),
      for (final message in messages)
        TicketEvent(
          id: 'evt-${message.id}',
          action: message.isAgent ? 'Agent reply' : 'Customer message',
          detail: message.body,
          actorName: message.authorName,
          at: message.createdAt,
        ),
      ...extraEvents,
    ]..sort((a, b) => a.at.compareTo(b.at));

    return Ticket(
      id: id,
      subject: subject,
      description: description,
      status: status,
      priority: priority,
      customerName: customerName,
      customerEmail: customerEmail,
      assigneeName: assigneeName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
      messages: messages,
      events: events,
      attachments: attachments,
    );
  }

  static const assignees = <String>[
    'Alex Rivera',
    'Sam Ortiz',
    'Jamie Fox',
    'Riley Nguyen',
  ];
}
