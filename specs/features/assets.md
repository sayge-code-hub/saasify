# Feature: Asset Management (MVP 1)

## Status

`in_progress`

## Summary

Admin module for tracking physical/logical assets (name, tag, type, location, parent, status). MVP 1 ships a mocked **Asset List** with search and CRUD, **Add Asset**, a simple **Asset Tree**, and **PM Schedule** (see `pm_schedule.md`). Responsive for phone, tablet, and web.

## Out of scope (later steps)

- Asset reports / summary / maintenance KPI reports
- Excel import, Change Management, Equipment Failure, Parts & Storage
- Work orders from PM Due
- Real API / persistence

## Screens (MVP 1)

| Screen | Route |
|--------|-------|
| Asset List | `/assets` |
| Add Asset | `/assets/new` |
| Asset Tree | `/assets/tree` |
| PM Schedule | `/assets/pm…` |
| Asset detail (edit) | `/assets/:id` |

## Acceptance criteria

- [x] Asset Management appears in the left module sidebar with MVP submodules
- [x] Asset List searchable; table on wide, cards on compact
- [x] Add / edit / delete assets in mock catalog
- [x] Asset Tree shows parent → child hierarchy from mock data
- [x] Responsive compact / medium / expanded
- [x] Cubit + page smoke tests

## State

- `AssetListCubit`: in-memory catalog, query, CRUD
