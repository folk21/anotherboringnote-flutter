#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 scripts/spec_state.py validate
if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter SDK missing: cannot run Dart formatting, analyzer or Flutter tests.' >&2
  exit 2
fi
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
