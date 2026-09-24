#!/usr/bin/env bash
# Build and serve the Saasify web release on port 43123.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
cd build/web
echo "Serving Saasify at http://127.0.0.1:43123"
exec python3 -m http.server 43123 --bind 0.0.0.0
