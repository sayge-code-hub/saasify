# Coding Standards

## Dart style

- Prefer `const` constructors wherever possible.
- Use explicit types on public APIs; infer locals when obvious.
- Prefer single quotes.
- Avoid `dynamic` unless interop forces it.
- No `print` in production paths; use debug-only logging if needed later.

## Widgets

- Keep build methods shallow; extract private or shared widgets early.
- Shared look-and-feel → `lib/core/widgets/`.
- Feature-only composition → `features/<f>/presentation/widgets/`.
- Do not wrap everything in cards. Cards are for interactive groupings only when the container itself aids understanding.

## Imports

- Package imports for `package:saasify/...`.
- Relative imports only within the same tightly coupled folder (prefer package imports for consistency).
- Never import `presentation` from `domain` or `data`.

## Error handling

- Map failures to typed domain/app failures in `core/errors` or feature domain.
- UI shows user-facing messages via state (`errorMessage`, empty, loading), never raw exceptions.

## Tests

- `bloc_test` for blocs/cubits.
- `flutter_test` for widgets.
- Name tests: `group('WidgetName')` / `'emits X when Y'`.
- Cover loading, success, failure for each bloc.

## Analyze & format

```bash
dart format .
flutter analyze
flutter test
```

Zero analyzer errors required. New ignores need justification in the PR/commit message.
