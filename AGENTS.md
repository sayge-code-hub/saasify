# Saasify — Agent Instructions

This file is the source of truth for any AI agent (Cursor, Claude, Copilot, etc.) working on **saasify**.

Read this file **before** writing code. Then read the relevant specs under `specs/`.

## Mission

Saasify is a Flutter app targeting **web and mobile** with one codebase. Work is **spec-driven**: implement only what specs and the current user prompt require. Do not invent product features.

## Non-negotiables

1. **Spec first** — If a requirement is not in `specs/` or the user prompt, do not build it. Add or update a spec before coding non-trivial behavior.
2. **BLoC only for state** — Presentation state lives in `Bloc` / `Cubit`. No `setState` for business or shared UI state. Local ephemeral UI (e.g. TextField focus) may stay in the widget.
3. **Clean feature layout** — New features go under `lib/features/<feature>/` with `data/`, `domain/`, `presentation/` as needed. Shared UI goes in `lib/core/widgets/`.
4. **No redundant code** — Reuse core widgets, theme tokens, and responsive helpers. Do not copy-paste page scaffolding.
5. **Responsive by default** — Use `AppBreakpoints` / `ResponsiveLayout`. Do not hardcode desktop-only layouts.
6. **Tests required** — Every Bloc/Cubit and every reusable widget gets tests. Run `flutter test` and `flutter analyze` before considering work done.
7. **Theme tokens only** — Colors, typography, spacing, radii come from `lib/core/theme/`. No magic numbers or raw hex in feature widgets unless extending the theme in one place.

## Where things live

| Concern | Location |
|--------|----------|
| App entry, DI, router | `lib/app/`, `lib/main.dart` |
| Theme, breakpoints, shared widgets | `lib/core/` |
| Product features | `lib/features/<name>/` |
| Architecture & coding rules | `specs/` |
| Cursor agent rules | `.cursor/rules/` |
| Tests mirror `lib/` | `test/` |

## Workflow for agents

1. Read `AGENTS.md` + `specs/architecture.md` + `specs/coding-standards.md`.
2. If the task changes UI or UX, also read `specs/theme.md` and `specs/responsive.md`.
3. If implementing a feature, check/update `specs/features/<feature>.md` first.
4. Implement the smallest vertical slice that matches the spec.
5. Add/update tests; run analyze + test.
6. Do not rewrite architecture, rename packages, or add state-management libraries without an explicit user request.

## Anti-haywire checklist

- Do **not** add auth, backend, Firebase, or databases unless the user asks.
- Do **not** introduce Riverpod, GetX, MobX, or Provider-as-primary-state.
- Do **not** put business logic in widgets.
- Do **not** create a second design system or parallel folder trees (`ui/`, `components/`, `shared/` outside `core/`).
- Do **not** leave TODO stubs for required behavior; either implement or document a deferred item in the feature spec.
- Prefer editing existing files over creating near-duplicates.

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 43123
flutter run  # device / emulator
```

## Current phase

**Admin SaaS shell + Ticketing (UI mocked).** Auth is in-memory. Next slices may wire APIs; do not invent backend packages unless asked.
