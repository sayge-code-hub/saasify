# Feature: Ticketing (admin UI, mocked)

## Status

`done` (UI mocked)

## Summary

Admin-facing customer-support ticketing UI. Data and workflows are mocked in memory so agents and stakeholders can review layout and basic flows before backend work.

## Screens

1. **Ticket list** (`/ticketing`, `/ticketing/open`, `/ticketing/pending`, `/ticketing/resolved`)
   - Search by subject / customer / id
   - Status segment filters (synced with route when applicable)
   - Priority filter
   - Sortable-feeling table/list: id, subject, customer, priority, status, assignee, updated
2. **Ticket detail** (`/ticketing/tickets/:id`)
   - Header with id + subject
   - Status workflow actions (Open → In progress → Pending → Resolved → Closed)
   - Priority + assignee chips (assignee change is UI mock dropdown)
   - Conversation thread + reply composer (reply appends locally)
   - Customer / meta aside

## Desktop layout

- Expanded: list is full-width; detail is a dedicated route (clean admin pattern)
- Compact: same routes, stacked

## Mock workflows

- Change status via action buttons (updates list + detail)
- Post reply as agent (appends message, bumps updated time)
- Search / filter without persistence

## Out of scope

- Real API, attachments upload, SLA clocks, email channel, CSAT

## Acceptance criteria

- [ ] Mock catalog has ≥8 tickets across statuses/priorities
- [ ] Filters and search update the visible list
- [ ] Opening a row navigates to detail
- [ ] Status transitions and replies update UI state
- [ ] Empty search/filter state uses `AppEmptyState`
- [ ] Cubits + key widgets tested

## State

- `TicketListCubit` — catalog, query, status/priority filters, derived visible list
- Detail mutations go through the same cubit (single source of truth for mock data)
