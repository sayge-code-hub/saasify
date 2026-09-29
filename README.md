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
- **Asset Management (MVP 1)** — Asset List, Add Asset, Asset Tree, PM Schedule (mocked, responsive)

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

## Host on Netlify (mocked data) + auto version bump

The app is a static Flutter web build. Mock data lives in the client — no backend required.

### How automation works

1. You push (or merge) to **`main`** on GitHub.
2. GitHub Action [`.github/workflows/release-version.yml`](./.github/workflows/release-version.yml) bumps the **patch** version (`1.1.2` → `1.1.3`) in:
   - `pubspec.yaml`
   - `lib/core/constants/app_constants.dart`
   - `lib/features/releases/data/release_notes.dart`
3. It commits `chore(release): vX.Y.Z` and pushes back to `main`.
4. Netlify (connected to this repo) builds **only** those release commits and publishes to **production**.

### One-time Netlify setup (required)

1. Open [Netlify → Add new site → Import an existing project](https://app.netlify.com/start).
2. Choose **GitHub** → authorize → select **`sayge-code-hub/saasify`**.
3. Confirm settings from [`netlify.toml`](./netlify.toml) (do not override):
   - Build command / publish dir come from the file
   - Production branch: **`main`**
4. Deploy. First Flutter build can take several minutes.

After that, every push to `main` → version bump → Netlify production deploy.

Mock login on the live site: any non-empty email/password (same as local).

### Manual CLI deploy (optional)

```bash
flutter pub get
flutter build web --release --no-wasm-dry-run
npx netlify-cli deploy --prod --dir=build/web
```
