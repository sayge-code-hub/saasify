# Responsive

## Breakpoints (`AppBreakpoints`)

| Name | Min width | Typical |
|------|-----------|---------|
| compact | 0 | phones |
| medium | 600 | large phones / small tablets |
| expanded | 1024 | desktop web |

## Shell behavior

| Width | Navigation |
|-------|------------|
| compact | bottom navigation |
| medium | navigation rail |
| expanded | navigation rail + wider content max-width |

## Content

- Prefer fluid layouts with `maxWidth` constraints for readable lines on desktop.
- Touch targets ≥ 48 logical pixels on compact.
- Avoid horizontal scroll for primary flows.

## Helpers

- `ResponsiveLayout` — builds different children by breakpoint
- `AppBreakpoints.of(context)` — current bucket
- `context.isCompact` / `isMedium` / `isExpanded` extensions
