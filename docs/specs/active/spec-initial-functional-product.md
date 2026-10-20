---
type: Specification
title: Initial Flutter functional product
description: Port the minimal offline note and reader experience onto Flutter without introducing unrelated product features.
document_role: umbrella
spec_status: active
current_focus: docs/specs/active/subspecs/flutter-port-parity/spec.md
---
# Initial Flutter functional product

## Outcome

Provide an independent Flutter/Dart application with the same essential offline-first note/editor/reader workflows as the KMP source and cross-platform interactive validation. Flutter must not depend on the KMP/JVM modules. Product scope remains deliberately minimal.

## Requirements

- `FP-R1`: Notes are untitled UTF-8 plain text. Native persistence uses separate `.txt` files and a backward-compatible version-1 metadata index.
- `FP-R2`: Users can list, create, edit, duplicate and delete notes; editor protects unsaved work and uses explicit destructive confirmation.
- `FP-R3`: Reader is full-window read-only text, offers Private/Normal/Large/Presentation modes, typography zoom, appearance and settings persistence.
- `FP-R4`: Android and macOS are primary target acceptance platforms; Flutter iOS and browser preview are enabled and individually assessed.
- `FP-R5`: All core behavior works offline, with no database/server/AI runtime dependency.
- `FP-R6`: Development follows MAIN/WORKER workflow with per-spec `implementation.md` and `STATE.json` controlled by MAIN/developer.

## Non-goals

Folders, tags, Markdown, accounts, synchronization, cloud AI, encrypted notes, canvas, plugins, KMP source reuse and automatic data migration.

## Acceptance

Follow the active bounded parity spec, actual tests and platform matrix in `docs/TESTS.md`. Until verified, implementation presence is not evidence of acceptance.
