# Feature: Dynamic UI (backend-driven forms)

## Status

`done` (mock JSON + local renderer)

## Summary

Server-driven screen module. A JSON document describes rows (max 2 fields), field types, validation, sticky buttons, dialogs, and API calls. The existing hard-coded Add Ticket page is unchanged; BDUI Add Ticket is a separate route that plots the same form from mock JSON.

## Route

- `/dynamic/create-ticket` — renders `assets/dynamic_ui/create_ticket_screen.json` (also embedded in `MockDynamicScreens`)

## JSON capabilities

- Rows with 1–2 fields
- Field types: `text`, `textarea`, `dropdown`, `radio`
- Required flag, hints, defaults, dropdown/radio options
- Sticky action bar; button variants; `validateForm`
- Actions: `navigate`, `toast`, `dismiss`, `dialog`, `api`, `sequence`
- API actions: method, url, headers, body with `{{field}}` templates, `onSuccess` / `onError`

## Acceptance criteria

- [x] Existing `/ticketing/new` untouched
- [x] New module under Dynamic UI nav
- [x] Create Ticket screen plotted from mock JSON
- [x] Save opens confirm dialog then mock POST `/api/tickets`
