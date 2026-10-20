---
type: Development Guide
title: Flutter repository agent rules
description: Source-of-truth, module ownership, safety, SDD, main-model/worker boundaries, and validation rules.
---
# Development rules

## Read order

1. Read `README.md` and this file.
2. Read the nearest `AGENTS.md` for files to be modified.
3. Read the current active spec (`spec.md`), its `implementation.md`, `STATE.json`, owning contract/current-state documents, code and tests.
4. Current repository bytes override older conversation context, source KMP snapshots, and model-created summaries.

## Product invariants

- Offline-first; no network requirement for CRUD/reader.
- Notes are title-less plain text with normalized `\n` line endings.
- Native storage: UTF-8 text plus versioned metadata, not a mandatory database.
- `formatVersion > 1` in a structurally recognized index/settings must not be silently rewritten by older code.
- Empty new notes do not persist; saving an existing note as empty requires explicit deletion confirmation.
- Reader is read-only. Presentation reuses Large size. Reflow zoom changes font size and wrapping, not a scaled canvas. Private mode does not provide confidentiality.
- Do not introduce folders, tags, sync, Markdown, attachments, accounts, AI features, web backend, or history without an approved active spec.

## Code ownership

- `lib/src/notes/`: note domain, lifecycle, persistence reconciliation, metadata contracts. Does not import reader/UI.
- `lib/src/reader/`: reader modes, preferences, font/color/orientation semantics. Does not import notes/UI.
- `lib/src/storage/`: platform-boundary file/browser storage implementations. `store.dart` is the pure seam.
- `lib/src/ui/`: Flutter screens/composition. References notes/reader/storage as needed. No persistence format parsing in widgets.
- `lib/main.dart`: application entry point only.

Prefer explicit state, minimal dependencies, testable domain semantics. Do not create generic architecture layers merely for symmetry. Use Dart's language/runtime facilities before adding libraries. Avoid `dart:io` imports in web-reachable common code; use conditional imports/exports.

## Model responsibilities

MAIN: maintain spec, `implementation.md`, stage decomposition, `STATE.json`, review, acceptance, current-state docs, architecture decisions, coordination. WORKER (currently Aider): read the approved stage, inspect code/tests, make scoped edits, run focused checks, report evidence. WORKER must not edit `STATE.json`, acceptance status, active normative specifications, or approve itself. No automatic merge, push, branch switching, weakening tests, or unsupported verification claims. Aider sees *read-only context* through `--read`; keep source edits scoped to the approved implementation file.

Follow [docs/ai/WORKFLOW.md](docs/ai/WORKFLOW.md). State transitions are managed via `python3 scripts/spec_state.py`, reviewed by MAIN/human, and committed to Git. `STATE.json` is the canonical persistent stage-state; chat context, Aider memory, implementation prose, and local `.git` metadata are not substitutes. `implementation.md` tells WORKER **how to implement**, not whether something is accepted.

## Spec lifecycle

Only active specs authorize implementation. Planned specs require promotion. Archive only after actual acceptance, updating owning current-state documents and evidence. Keep active specs bounded and preserve requirement/feature IDs. Source KMP documents under `docs/reference/kmp-source/` are frozen provenance, not active Flutter rules.

## Testing and documentation

Behavior change => smallest deterministic test + appropriate broader gate. Run `bash scripts/run_checks.sh` when Flutter SDK is present. Never describe a command as passed unless it actually passed. Record platform/manual acceptance separately. Use English for ALL code/config comments and software documentation. Prefer owning docs over duplicative commentary. Follow `docs/TESTS.md`.

## Repository hygiene

Never commit SDK caches, `.dart_tool`, `build/`, local user notes, secrets, `ABN_DATA_DIR`, temporary Aider messages, `.ai-runtime/`, generated concatenated snapshots or tool logs. Generated native runner source (`android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/`) **should be committed after bootstrap**; generated build intermediates within them should not.

On an implementation task: identify stage and owner, inspect contract/tests, make a bounded edit, validate, report actual checks and remaining uncertainty, and leave acceptance/state updates to MAIN and developer. A full separate-repository archive is not a PATCH to KMP.
