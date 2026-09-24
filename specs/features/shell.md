# Feature: App shell (SaaS modules)

## Status

`done`

## Summary

Authenticated admin chrome with a left module bar. Top-level modules expand to reveal submodules. Compact widths use a drawer with the same hierarchy.

## Modules (v1)

| Module | Submodules | Route prefix |
|--------|------------|--------------|
| Overview | — | `/` |
| Ticketing | All tickets, Open, Pending, Resolved | `/ticketing…` |
| Settings | — | `/settings` |

## Acceptance criteria

- [ ] Expanded/medium: persistent left sidebar with expand/collapse modules
- [ ] Compact: menu opens drawer with same nav
- [ ] Active submodule highlighted from current route
- [ ] Sign-out control available in shell header
- [ ] No bottom-nav dual-destination pattern for admin

## Out of scope

- Per-role module permissions
- Drag-reorder modules
