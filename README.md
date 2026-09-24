# Saasify

Spec-driven Flutter foundation for **web and mobile**, built with BLoC, a clean feature layout, shared widgets, and agent guardrails so follow-up prompts stay on track.

> **Local path note:** This repo is the Saasify project. On your machine you can clone or sync it under `/Users/aditya/StudioProjects/saasify` (or open this workspace in Android Studio / VS Code / Cursor).

## Stack

- Flutter 3.47+ (Android, iOS, Web, desktop targets scaffolded)
- State: `flutter_bloc` + `equatable`
- Routing: `go_router`
- Theme fonts: Fraunces + Source Sans 3 via `google_fonts`

## Spec-driven workflow

Read these **before** coding (especially with AI agents):

| File | Role |
|------|------|
| [`AGENTS.md`](./AGENTS.md) | Agent contract — non-negotiables |
| [`specs/`](./specs/) | Architecture, theme, responsive, feature specs |
| [`.cursor/rules/`](./.cursor/rules/) | Cursor rules wired to the same contracts |

Product features are implemented only after a feature spec exists under `specs/features/`.

## Project structure

```
lib/
  main.dart
  app/                 # MaterialApp, router
  core/
    theme/             # colors, spacing, typography, ThemeData
    responsive/        # breakpoints + ResponsiveLayout
    widgets/           # reusable UI primitives
    constants/
    errors/
  features/
    shell/             # adaptive navigation chrome
    home/              # foundation placeholder
specs/                 # living requirements
test/                  # mirrors lib/
```

## Run locally

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 43123
flutter run   # iOS / Android device or emulator
```

## What’s in the foundation

- Light enterprise theme (slate + teal) with tokenized spacing
- Adaptive shell: bottom nav (phone) / navigation rail (tablet & desktop)
- Reusable widgets: button, text field, page, loading, empty, error
- `ShellCubit` + unit/widget tests
- Agent files to keep future coding prompts aligned

## Next

Share product requirements in the next prompt. They will be captured as feature specs, then implemented slice-by-slice against those specs.
