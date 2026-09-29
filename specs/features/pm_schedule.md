# Feature: PM Schedule (Preventive Maintenance)

## Status

`in_progress` (MVP slice)

## Summary

Preventive maintenance plans linked to assets answer “What maintenance is due for Pump A?”. Each PM plan has frequency, next due, team/technician, checklist, instructions, and status. Completing a plan advances the next due date (mock). Later: PM Due → Work Order → history (ties into Ticketing).

## Screens

| Screen | Route |
|--------|-------|
| PM Schedule list | `/assets/pm` |
| Add PM Plan | `/assets/pm/new` |
| PM detail | `/assets/pm/:pmId` |
| Edit PM Plan | `/assets/pm/:pmId/edit` |

Asset detail shows related PM plans and links to filtered schedule (`?asset=`).

## Acceptance criteria

- [x] Sidebar: Asset Management → PM Schedule
- [x] List searchable; overdue / due soon sorted first
- [x] Detail shows checklist (toggle), instructions, mark completed
- [x] Create / edit PM plan form
- [x] Linked from asset detail
- [x] Responsive + cubit tests

## Out of scope (next)

- Work Order generation from PM Due
- Meter-based triggers / readings
- Full maintenance history ledger
