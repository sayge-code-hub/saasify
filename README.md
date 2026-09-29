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
- **Ticketing admin** — list/search/filters, detail with assignee + SLA, reply thread, configurable dropdowns (all mocked)

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

## Publish to GitHub

Target repo: [sayge-code-hub/saasify](https://github.com/sayge-code-hub/saasify)

From a machine that has access to that GitHub org (your Mac):

```bash
# clone / open this project, then:
git remote add github https://github.com/sayge-code-hub/saasify.git
# or, if you want GitHub as the main remote:
# git remote set-url origin https://github.com/sayge-code-hub/saasify.git

git push -u github main
```

If the GitHub repo is empty, that push becomes the initial `main`.  
If it already has commits (e.g. a README), use one of:

```bash
git pull github main --allow-unrelated-histories
# resolve any conflicts, then:
git push -u github main
```

or, only if you intend to overwrite the remote history:

```bash
git push -u github main --force
```

## Host on Netlify (mocked data)

The app is a static Flutter web build. Mock data lives in the client — no backend required.

### Option A — Git-connected (recommended)

1. Push to GitHub (above).
2. In [Netlify](https://app.netlify.com): **Add new site → Import an existing project → GitHub → `sayge-code-hub/saasify`**.
3. Netlify reads [`netlify.toml`](./netlify.toml):
   - **Build command** installs Flutter and runs `flutter build web --release`
   - **Publish directory** `build/web`
   - SPA redirects so deep links like `/ticketing/tickets/TCK-1012` work
4. Deploy. First build can take several minutes (Flutter SDK download).

Mock login on the live site: any non-empty email/password (same as local).

### Option B — Manual CLI deploy (no Netlify build)

```bash
flutter pub get
flutter build web --release --no-wasm-dry-run
npx netlify-cli deploy --prod --dir=build/web
```

Link the site to the GitHub repo in Netlify settings when prompted so later deploys can use Option A.
