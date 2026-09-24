# Theme

## Direction

Orange · black · pure white. Sharp and commercial — not teal SaaS, not cream editorial, not purple gradient.

## Tokens (source of truth)

Defined in `lib/core/theme/`:

| Token group | File |
|-------------|------|
| Color palette | `app_colors.dart` |
| Spacing / radii | `app_spacing.dart` |
| Typography | `app_typography.dart` |
| ThemeData assembly | `app_theme.dart` |

## Color roles

- **Canvas / surface**: pure white (`#FFFFFF`) everywhere
- **Ink**: near-black for primary text
- **Accent**: orange (`#E85D04`) for primary actions and brand marks
- **Danger / success / warning**: semantic only

## Typography

- Display / titles: **Fraunces**
- Body / UI: **Source Sans 3**

Access only through `Theme.of(context).textTheme` or `AppTypography`.

## Spacing scale

4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 — use `AppSpacing.*`.

## Motion

Subtle, purposeful:

- Login entrance fade + slide
- Orange accent underline settle
- Shell navigation indicator

Do not add continuous decorative animations.
