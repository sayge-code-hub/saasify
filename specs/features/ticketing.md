# Feature: Ticketing (admin UI, mocked)

## Status

`done` (UI mocked)

## Summary

Admin-facing customer-support ticketing UI. Data and workflows are mocked in memory so agents and stakeholders can review layout and basic flows before backend work.

## Screens

1. **Dashboard** (`/ticketing`) — status / priority analytics (see overview spec)
2. **Add Ticket** (`/ticketing/new`) — create form: Header, Application, Priority, Bug, Responsibility, Affected Equipment, Description, Distribution List
3. **Ticket list** (`/ticketing/all`, `/open`, `/pending`, `/resolved`, `/priority`)
   - Search by subject / customer / id
   - Export Excel / PDF / Email (mocked)
   - Select all / deselect all / per-row selection
   - Bulk delete when selection is non-empty
   - Clean list: id, subject, customer, priority, status, assignee
4. **Ticket detail** (`/ticketing/tickets/:id`)
   - Top bar: back + All tickets (not ticket id title)
   - 70/30 layout: details + comments | attachments then timeline
   - No workflow action bar on the page
5. **Config** (`/ticketing/config`) — placeholder queue preferences

## Mock workflows

- Create ticket via Add Ticket (prepends to catalog, opens detail)
- Change status via action buttons
- Post reply as agent
- Search / filter without persistence

## Acceptance criteria

- [x] Mock catalog has ≥8 tickets across statuses/priorities
- [x] Filters and search update the visible list
- [x] Opening a row navigates to detail
- [x] Status transitions and replies update UI state
- [x] Create case adds a ticket to the mock catalog
- [x] Cubits + key widgets tested
