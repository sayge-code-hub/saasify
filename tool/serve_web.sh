#!/usr/bin/env bash
# Build and serve the Saasify web release on port 43123 (SPA path routes).
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
echo "Serving Saasify at http://127.0.0.1:43123"
exec python3 tool/spa_server.py --port 43123 --bind 0.0.0.0 --directory build/web
