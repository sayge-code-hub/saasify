#!/usr/bin/env bash
# Bump patch version across pubspec, AppConstants, and ReleaseNotes.
# Usage: tool/bump_version.sh
# Prints the new semver (e.g. 1.1.3) to stdout (last line).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$ROOT/pubspec.yaml"
CONSTANTS="$ROOT/lib/core/constants/app_constants.dart"
RELEASES="$ROOT/lib/features/releases/data/release_notes.dart"

current="$(sed -nE 's/^version: ([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)$/\1+\2/p' "$PUBSPEC" | head -1)"
if [[ -z "$current" ]]; then
  echo "Could not parse version from pubspec.yaml" >&2
  exit 1
fi

name="${current%%+*}"
build="${current##*+}"
IFS=. read -r major minor patch <<<"$name"
new_patch=$((patch + 1))
new_build=$((build + 1))
new_name="${major}.${minor}.${new_patch}"
new_full="${new_name}+${new_build}"
year="$(date -u +%Y)"
month="$(date -u +%-m)"
day="$(date -u +%-d)"

sed -i -E "s/^version: .*/version: ${new_full}/" "$PUBSPEC"
sed -i -E "s/static const String appVersion = '[0-9]+\.[0-9]+\.[0-9]+';/static const String appVersion = '${new_name}';/" "$CONSTANTS"
sed -i -E "s/static const currentVersion = '[0-9]+\.[0-9]+\.[0-9]+';/static const currentVersion = '${new_name}';/" "$RELEASES"

NEW_NAME="$new_name" YEAR="$year" MONTH="$month" DAY="$day" RELEASES="$RELEASES" python3 - <<'PY'
import os
from pathlib import Path

path = Path(os.environ["RELEASES"])
new_name = os.environ["NEW_NAME"]
year = int(os.environ["YEAR"])
month = int(os.environ["MONTH"])
day = int(os.environ["DAY"])
text = path.read_text()
marker = "static final List<AppRelease> all = [\n"
entry = f"""    AppRelease(
      version: '{new_name}',
      releasedAt: DateTime.utc({year}, {month}, {day}),
      title: 'Production deploy',
      changes: const [
        ReleaseChange(
          type: ReleaseChangeType.improvement,
          summary: 'Automated release {new_name} published to production.',
        ),
      ],
    ),
"""
if f"version: '{new_name}'" in text.split("static final List<AppRelease> all = [", 1)[-1][:400]:
    pass
elif marker not in text:
    raise SystemExit("ReleaseNotes list marker not found")
else:
    path.write_text(text.replace(marker, marker + entry, 1))
PY

echo "Bumped ${current} → ${new_full}" >&2
echo "${new_name}"
