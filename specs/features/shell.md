# Feature: App shell

## Status

`done` (foundation)

## Summary

Responsive application chrome for Saasify: branded top bar, adaptive navigation, and a home placeholder route. Product features plug into this shell later.

## Out of scope

- Auth
- Real product modules
- Persistence

## Acceptance criteria

- [x] Compact: bottom navigation
- [x] Medium/expanded: navigation rail
- [x] Home route renders branded placeholder
- [x] Theme applied globally
- [x] Shell navigation Cubit tested
- [x] Responsive helpers tested

## State

- `ShellCubit` tracks selected destination index
- Destinations: Home, Settings (extensible list in `ShellDestinations`)

## UI notes

- Brand name "Saasify" visible in shell header
- Content area uses `AppPage` padding and max-width
