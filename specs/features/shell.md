# Feature: App shell (SaaS modules)

## Status

`done`

## Summary

Authenticated admin chrome with a Maglo-inspired layout: left module sidebar (uploadable company logo, orange active underline, Help/Logout, Saasify wordmark + Powered by Sayge + version), top dashboard header (title or stacked date/time on home, search, notifications, settings, account), and page content filling the remaining column. Top-level modules expand to reveal submodules. Compact widths use a drawer with the same hierarchy.

## Modules (v1)

| Module | Submodules | Route prefix |
|--------|------------|--------------|
| Ticketing | Dashboard, Add Ticket, All Tickets, Config | `/ticketing…` |
| Asset Management (MVP 1) | Asset List, Add Asset, Asset Tree | `/assets…` |
| Dynamic UI | BDUI Add Ticket (backend-driven form demo) | `/dynamic/create-ticket` |

Clicking **Ticketing** opens the Dashboard (`/ticketing`) and expands the submodule list. **Settings** lives in the top header (gear icon), not the sidebar. Active nav is marked with a solid accent underline (not a filled pill).

## Acceptance criteria

- [x] Expanded/medium: persistent left sidebar with expand/collapse modules
- [x] Compact: menu opens drawer with same nav
- [x] Active submodule highlighted from current route
- [x] Sign-out control available in shell header
- [x] No bottom-nav dual-destination pattern for admin
- [x] Sidebar brand slot shows company logo (or placeholder); Saasify + Sayge footer at bottom
- [x] Dashboard home header shows stacked date / time

## Out of scope

- Per-role module permissions
- Drag-reorder modules
