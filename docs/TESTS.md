---
type: Testing Guide
title: Validation and manual acceptance
description: Checks runnable locally, stage-state validation, and native/web manual acceptance matrix.
---
# Validation

## Automated repository gate

```bash
python3 scripts/spec_state.py validate
bash scripts/run_checks.sh
```

The script invokes Flutter dependency resolution, non-mutating Dart format checking, `flutter analyze`, and `flutter test`. The code bundle was produced without a Flutter SDK, so **none of those Flutter commands have been executed here**. Only separately recorded checks may be reported as passed. Do not mark the port accepted merely because static Python state validation succeeds.

## Dart tests

- `test/note_repository_test.dart`: note text normalization, create/duplicate ordering, index reconciliation and future-version protection, rollback after simulated write failure.
- `test/reader_test.dart`: semantic mode sizes, zoom isolation, settings codec/default fallback.
- `test/widget_smoke_test.dart`: empty list UI and creation action.

## Manual platform acceptance (evidence required)

| Target | Required actions | Status at packaging |
|---|---|---|
| Chrome | new/edit/duplicate/delete, reader settings, large window and narrow viewport, browser persistence after refresh | Not run |
| macOS x64 Intel | sandbox-contained file inspection, app restart, keyboard zoom, Ctrl/Cmd+wheel, dialogs, native fonts, resize/scroll/accessibility | Not run |
| Android device/emulator | pinch vs one-finger scroll, Back, rotate, Presentation landscape restore, dark/system text scale, new/edit, file isolation | Not run |
| iOS simulator | safe areas, navigation, keyboard, landscape policy, note persistence, font picker availability | Not run |
| Windows and Linux | native file replace/backup and UI interaction with generated host runners | Not run |

For each accepted stage, store exact commands, exit code, platform/device/build version and tester observations in `docs/specs/active/subspecs/flutter-port-parity/evidence/` or a Git-linked issue/PR. Supply that reference to `scripts/spec_state.py verify --evidence ...`; a human is responsible for the truth of the evidence.

For a sandboxed macOS smoke test, use `ABN_DATA_DIR=abn-flutter-smoke flutter run -d macos` (a relative path). An absolute `/tmp` override is not a valid default smoke test because App Sandbox may block it.

## Quality bars

No test is disabled to satisfy the worker. If a real platform check fails, do not claim acceptance. Keep that stage `blocked` or `verification_pending` and record the defect. Flutter's native window, orientation, font-file interactions and plugin implementations cannot be proved by pure domain tests.
