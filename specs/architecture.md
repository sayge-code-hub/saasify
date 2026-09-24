# Architecture

## Stack

- Flutter (web + iOS + Android; desktop targets scaffolded)
- State: `flutter_bloc` (Bloc / Cubit) + `equatable`
- Routing: `go_router`
- Typography: `google_fonts` via theme only

## Layering

```
presentation  →  domain  →  data
     ↑                         │
     └─────────── (interfaces)─┘
```

- **presentation**: pages, feature widgets, blocs/cubits
- **domain**: entities, repository interfaces, use cases (add when a feature needs them)
- **data**: DTOs, API/local sources, repository implementations (add when needed)

Dependencies point inward. Widgets never import `data/` directly.

## Folder map

```
lib/
  main.dart                 # bootstrap only
  app/
    app.dart                # MaterialApp.router + global providers
    router/app_router.dart
  core/
    theme/                  # tokens + ThemeData
    constants/
    responsive/             # breakpoints + layout helpers
    widgets/                # reusable, feature-agnostic widgets
    utils/
    errors/
  features/
    <feature>/
      data/
      domain/
      presentation/
        bloc/
        pages/
        widgets/
```

## BLoC conventions

- One Bloc/Cubit per cohesive UI concern.
- Events and states are immutable and extend `Equatable` (or use sealed classes with value equality).
- Name files: `<name>_bloc.dart`, `<name>_event.dart`, `<name>_state.dart` (or single-file Cubit when small).
- Provide blocs as close to the consumer as practical; app-wide only when truly global.
- Prefer Cubit when there is a single intent stream with no distinct event types.

## Routing

- All routes defined in `app_router.dart`.
- Feature pages do not own navigation graphs.
- Deep links must remain valid on web.

## Responsiveness

- Breakpoints live in `AppBreakpoints`.
- Shell switches between navigation rail / drawer / bottom bar per `specs/responsive.md`.

## Testing pyramid

1. Unit: blocs, pure utils
2. Widget: core widgets + feature pages smoke tests
3. Golden tests optional; add when UI stabilizes
