# Saasify

Spec-driven Flutter SaaS admin for **web and mobile**. Current slice: mocked login, module sidebar, and **Ticketing** admin UI.

## Try it

```bash
flutter pub get
flutter run -d chrome --web-port 43123
```

Mock login: any non-empty email/password (prefilled `admin@saasify.io` / `password`).

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
