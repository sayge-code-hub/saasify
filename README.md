# Saasify

Spec-driven Flutter SaaS admin for **web and mobile**. Current slice: mocked login, module sidebar, and **Ticketing** admin UI.

## Try it

```bash
flutter pub get
# Reliable web preview (release build + local CanvasKit):
bash tool/serve_web.sh
# Open http://127.0.0.1:43123 and hard-refresh once (Ctrl+Shift+R)
```

Or device/emulator: `flutter run`

Mock login: any non-empty email/password (prefilled `admin@saasify.io` / `password`).

If you see “Loading workspace…” forever, hard-refresh to clear a stale Flutter service worker from an older debug run.

## What’s built

- **Login** — gated routes, in-memory session
- **Shell** — left module bar with expandable **Ticketing** submodules (drawer on compact)
- **Overview** — ticket pulse stats + urgent queue
- **Ticketing admin** — list/search/filters, detail, status workflow, assignee, reply thread (all mocked)

## Spec-driven workflow

| File | Role |
|------|------|
| [`AGENTS.md`](./AGENTS.md) | Agent contract |
| [`specs/`](./specs/) | Architecture + feature specs |
| [`.cursor/rules/`](./.cursor/rules/) | Cursor rules |

## Structure

```
lib/
  app/                 # MaterialApp, go_router + auth redirects
  core/                # theme, breakpoints, shared widgets
  features/
    auth/
    shell/
    overview/
    ticketing/         # domain + mock data + admin UI
    settings/
```

## Quality

```bash
flutter analyze
flutter test
```
