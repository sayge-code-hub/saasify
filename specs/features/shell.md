# Feature: App shell (SaaS modules)

## Status

`done`

## Summary

Authenticated admin chrome with a Maglo-inspired layout: left module sidebar (wordmark, orange active pills, Help/Logout), top dashboard header (title, search, notifications, account), and page content filling the remaining column. Top-level modules expand to reveal submodules. Compact widths use a drawer with the same hierarchy.

## Modules (v1)

| Module | Submodules | Route prefix |
|--------|------------|--------------|
| Ticketing | Dashboard, Add Ticket, All Tickets, Open Tickets, Pending Tickets, Resolved Tickets, Priority Tickets, Config | `/ticketing…` |

Clicking **Ticketing** opens the Dashboard (`/ticketing`) and expands the submodule list. **Settings** lives in the top header (gear icon), not the sidebar. Active nav uses a soft orange gradient with white labels.

## Acceptance criteria

- [x] Expanded/medium: persistent left sidebar with expand/collapse modules
- [x] Compact: menu opens drawer with same nav
- [x] Active submodule highlighted from current route
- [x] Sign-out control available in shell header
- [x] No bottom-nav dual-destination pattern for admin

## Out of scope

- Per-role module permissions
- Drag-reorder modules
