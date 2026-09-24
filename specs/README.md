# Specs

Specs define what agents and humans may build. Code follows specs, not the other way around.

## Index

| Spec | Purpose |
|------|---------|
| [architecture.md](./architecture.md) | Layers, folders, BLoC rules, dependency direction |
| [coding-standards.md](./coding-standards.md) | Dart/Flutter conventions, testing, PR quality bar |
| [theme.md](./theme.md) | Colors, type, spacing, motion tokens |
| [responsive.md](./responsive.md) | Breakpoints and adaptive layout rules |
| [features/_template.md](./features/_template.md) | Template for new feature specs |
| [features/auth.md](./features/auth.md) | Mocked login / session gate |
| [features/shell.md](./features/shell.md) | SaaS module sidebar + submodules |
| [features/overview.md](./features/overview.md) | Post-login dashboard |
| [features/ticketing.md](./features/ticketing.md) | Admin ticketing UI (mocked) |
| [features/settings.md](./features/settings.md) | Settings placeholder |

## How to add a requirement

1. Create or update `specs/features/<name>.md` from the template.
2. List acceptance criteria as testable bullets.
3. Implement against that spec only.
4. Keep the spec updated when behavior changes intentionally.
