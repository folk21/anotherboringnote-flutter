#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter SDK is not on PATH. Follow docs/INSTALLATION.md.' >&2
  exit 1
fi

flutter create --project-name anotherboringnote_flutter --org com.peiwae \
  --platforms=android,ios,macos,web,windows,linux .
python3 scripts/configure_macos_entitlements.py
flutter pub get
dart format lib test
printf '\nAvailable Flutter devices:\n'
flutter devices
printf '\nUse flutter run -d macos or flutter run -d chrome.\n'
