# Theme

## Direction

Enterprise SaaS, calm and precise. Cool slate surfaces with a teal accent. Not purple-gradient, not cream/terracotta editorial, not dark-by-default.

## Tokens (source of truth)

Defined in `lib/core/theme/`:

| Token group | File |
|-------------|------|
| Color palette | `app_colors.dart` |
| Spacing / radii | `app_spacing.dart` |
| Typography | `app_typography.dart` |
| ThemeData assembly | `app_theme.dart` |

## Color roles

- **Canvas**: cool off-white with a faint blue cast
- **Surface**: white / elevated white
- **Ink**: near-slate for primary text
- **Accent**: teal (`#0F766E` family) for primary actions
- **Danger / success / warning**: semantic only, not decoration

Light theme is primary. Dark theme may be added later via the same token files — do not invent a parallel dark palette in widgets.

## Typography

- Display / titles: **Fraunces** (expressive, brand-forward)
- Body / UI: **Source Sans 3** (readable, neutral)

Access only through `Theme.of(context).textTheme` or `AppTypography`.

## Spacing scale

4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 — use `AppSpacing.*`.

## Motion

Subtle, purposeful:

- Page fade/slide via router transitions (short)
- Primary button press scale (subtle)
- Shell navigation indicator animation

Do not add continuous decorative animations.
