---
type: Roadmap
title: Flutter conversion roadmap
description: Source scaffold position and verified stage progression.
---
# Roadmap

The initial Flutter source port is written but is **not yet compiled or device-accepted**. Canonical machine-readable stage status is in `docs/specs/active/subspecs/flutter-port-parity/STATE.json`.

1. **S01 domain/persistence verification:** resolve Flutter SDK dependency graph, format/analyze/test, verify format-version compatibility, storage/rollback tests; close only with evidence.
2. **S02 interaction verification:** smoke screens and workflows, fix observed differences between Compose and Flutter; validate before acceptance.
3. **S03 platform acceptance:** macOS x64, Chrome, Android, iOS; file dialogs, fonts, gestures, orientation, platform runners, safe storage, accessibility. Use bounded worker tasks for actual defects.
4. **S04 final parity/port acceptance:** cross-platform evidence, audit against the frozen KMP contract references, update docs and archive spec.

Future features (Markdown, folders, sync, online AI, Web production release) are out of current scope.
