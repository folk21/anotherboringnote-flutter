---
type: Specification
title: Flutter port parity and acceptance
description: Bounded functional, storage and platform port criteria for the first standalone Flutter release.
document_role: subspec
spec_status: verification-pending
parent: docs/specs/active/spec-initial-functional-product.md
---
# Flutter port parity

## Scope

Port the current notes and read-only reader experience from KMP/Compose into a fully separate Flutter application. Frozen KMP references under `docs/reference/kmp-source/` define source semantics for comparison; current Flutter contracts and this spec own the target.

## Functional criteria

- `PORT-R1`: No titles; preview first two visual lines; CRUD is locally durable and sorts by most recent update with deterministic ties.
- `PORT-R2`: New whitespace-only drafts create nothing; empty existing-note saves demand confirmation; leaving dirty editor demands confirmation.
- `PORT-R3`: Native notes are UTF-8 `.txt`, index is version-1 metadata, unknown future index version is never overwritten, and readable note files allow recovery from missing/malformed metadata.
- `PORT-R4`: Reader is read-only and uses exactly four semantic modes; Presentation reuses Large, and zoom is reflow-only with 8..240sp bounds.
- `PORT-R5`: Default mode, sizes, orientation, colors and font selection persist independently from note text. Private mode is not a security boundary.
- `PORT-R6`: Desktop zoom (buttons and keyboard), mobile pinch, orientation policy and reader-exit restoration preserve expected platform interaction.
- `PORT-R7`: Fonts have built-in fallback and imported TTF/OTF binaries are copied into app-owned storage, not referenced by arbitrary absolute paths.
- `PORT-R8`: macOS, Android and iOS are target runtimes subject to separate checks; browser provides local UI preview only; Windows/Linux are generated targets but require native-host acceptance.
- `PORT-R9`: Developer setup explains Intel x64 macOS, `flutter create` runner bootstrap and concrete UI smoke commands.
- `PORT-R10`: Each worker stage is MAIN-defined in `implementation.md` and tracked only by `STATE.json` after review and evidence.

## Compatibility and failure rules

Data roots are isolated from KMP by default. Unrecognized future versions must not be downgraded. Disk/plugin errors must be visible, not hidden as success. Automated schema tests alone do not verify mobile gestures or orientation.

## Non-goals

No automatic migration, cross-app live sharing, data sync, SQLite or backend, feature expansion or release signing.

## Acceptance evidence

Stage criteria are in `implementation.md`; current stage state is in `STATE.json`. Human review, real command output, on-device actions, and owner-doc synchronization are required before accepting each stage.
