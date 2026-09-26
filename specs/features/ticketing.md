# Feature: Ticketing (admin UI, mocked)

## Status

`in_progress` (UI mocked; config + SLA + assignee added)

## Summary

Admin-facing customer-support ticketing UI. Data and workflows are mocked in memory so agents and stakeholders can review layout and basic flows before backend work.

## Screens

1. **Dashboard** (`/ticketing`) — status / priority analytics (see overview spec)
2. **Add Ticket** (`/ticketing/new`) — create form: Header, Application, Priority, Bug, Responsibility, Affected Equipment, Description, Distribution List
   - Application, Priority, Bug, and Distribution List options come from **Config**
3. **Ticket list** (`/ticketing/all`)
   - Search by subject / customer / id
   - Export Excel / PDF / Email (mocked)
   - Select all / deselect all / per-row selection
   - Bulk delete when selection is non-empty
   - Clean list: id, subject, customer, priority, status, assignee
4. **Ticket detail** (`/ticketing/tickets/:id`)
   - 70/30 layout: details + comments | attachments then timeline
   - Change **Assignee** via dropdown (options from Config)
   - Categorized equal-size chips: Status, Priority, SLA, Tags
   - **SLA** panel: first response + resolution clocks
5. **Config** (`/ticketing/config`) — editable dropdown lists, enabled priorities, SLA hours per priority

## SLA model

A Service Level Agreement is the promised time to act on a ticket, by priority:

| Clock | Starts | Ends |
|-------|--------|------|
| First response | Ticket created | First agent comment |
| Resolution | Ticket created | Status becomes Resolved or Closed |

Status:

- **On track** — open and comfortably within target
- **At risk** — open with ≤20% of target time remaining
- **Breached** — deadline passed while still open
- **Met** / **Met late** — completed before / after the deadline

Default targets (hours): Urgent 1/4, High 4/24, Medium 8/72, Low 24/120 (response / resolution).

## Mock workflows

- Create ticket via Add Ticket (prepends to catalog, opens detail)
- Change assignee on detail
- Post reply as agent (starts first-response SLA completion)
- Edit dropdown options and SLA targets in Config
- Search / filter without persistence

## Acceptance criteria

- [x] Mock catalog has ≥8 tickets across statuses/priorities
- [x] Filters and search update the visible list
- [x] Opening a row navigates to detail
- [x] Replies update UI state
- [x] Create case adds a ticket to the mock catalog
- [x] Assignee can be changed on detail
- [x] Create-form dropdowns are driven by Config
- [x] SLA evaluate + display on detail
- [x] Cubits + key widgets tested
