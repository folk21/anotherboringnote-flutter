#!/usr/bin/env python3
"""Enable user-selected read-only access for native macOS font import."""

import plistlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
for name in ('DebugProfile.entitlements', 'Release.entitlements'):
    path = ROOT / 'macos/Runner' / name
    if not path.is_file():
        raise SystemExit(f'Missing generated macOS runner entitlement file: {path}')
    with path.open('rb') as handle:
        payload = plistlib.load(handle)
    payload['com.apple.security.files.user-selected.read-only'] = True
    with path.open('wb') as handle:
        plistlib.dump(payload, handle)
    print(f'Configured macOS font picker entitlement: {name}')
