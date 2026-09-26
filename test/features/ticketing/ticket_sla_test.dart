import 'package:flutter_test/flutter_test.dart';

import 'package:saasify/features/ticketing/domain/ticket.dart';
import 'package:saasify/features/ticketing/domain/ticket_config.dart';
import 'package:saasify/features/ticketing/domain/ticket_sla.dart';

void main() {
  final config = TicketConfig.defaults();
  final created = DateTime(2026, 9, 26, 10);

  Ticket ticket({
    TicketPriority priority = TicketPriority.high,
    TicketStatus status = TicketStatus.open,
    List<TicketMessage> messages = const [],
    DateTime? firstRespondedAt,
    DateTime? resolvedAt,
    DateTime? updatedAt,
  }) {
    return Ticket(
      id: 'TCK-1',
      subject: 'SLA case',
      description: 'Test',
      status: status,
      priority: priority,
      customerName: 'Ada',
      customerEmail: 'ada@example.com',
      createdAt: created,
      updatedAt: updatedAt ?? created,
      messages: messages,
      firstRespondedAt: firstRespondedAt,
      resolvedAt: resolvedAt,
    );
  }

  test('open ticket within target is on track', () {
    final snapshot = TicketSla.evaluate(
      ticket: ticket(),
      config: config,
      now: created.add(const Duration(hours: 1)),
    );

    expect(snapshot.firstResponse.status, SlaClockStatus.onTrack);
    expect(snapshot.resolution.status, SlaClockStatus.onTrack);
  });

  test('open ticket near deadline is at risk', () {
    // High first response = 4h; at 3.5h → 12.5% left → at risk (≤20%).
    final snapshot = TicketSla.evaluate(
      ticket: ticket(),
      config: config,
      now: created.add(const Duration(hours: 3, minutes: 30)),
    );

    expect(snapshot.firstResponse.status, SlaClockStatus.atRisk);
  });

  test('missed first response is breached until agent replies', () {
    final snapshot = TicketSla.evaluate(
      ticket: ticket(),
      config: config,
      now: created.add(const Duration(hours: 5)),
    );

    expect(snapshot.firstResponse.status, SlaClockStatus.breached);
  });

  test('agent reply within target marks first response met', () {
    final responded = created.add(const Duration(hours: 2));
    final snapshot = TicketSla.evaluate(
      ticket: ticket(firstRespondedAt: responded),
      config: config,
      now: created.add(const Duration(hours: 6)),
    );

    expect(snapshot.firstResponse.status, SlaClockStatus.met);
    expect(snapshot.firstResponse.completedAt, responded);
  });

  test('late resolution is met late', () {
    final resolved = created.add(const Duration(hours: 30));
    final snapshot = TicketSla.evaluate(
      ticket: ticket(
        status: TicketStatus.resolved,
        firstRespondedAt: created.add(const Duration(hours: 1)),
        resolvedAt: resolved,
        updatedAt: resolved,
      ),
      config: config,
      now: resolved,
    );

    expect(snapshot.resolution.status, SlaClockStatus.metLate);
  });

  test('formatDuration renders compact units', () {
    expect(TicketSla.formatDuration(const Duration(hours: 4)), '4h');
    expect(TicketSla.formatDuration(const Duration(days: 2, hours: 3)), '2d 3h');
    expect(TicketSla.formatDuration(const Duration(minutes: 45)), '45m');
  });
}
