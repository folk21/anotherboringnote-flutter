---
type: Implementation
title: Current Flutter implementation
description: Actual code mapping and unverified integration boundaries.
---
# Current implementation

> Source presence is documented here; final runtime acceptance and compilation are tracked separately in the active spec's STATE.json.

| Responsibility | Source |
|---|---|
| Startup and app composition | `lib/main.dart`, `lib/src/ui/app.dart` |
| Note identity, normalization, sort order | `lib/src/notes/note.dart` |
| Index reconciliation, CRUD, rollback | `lib/src/notes/note_repository.dart` |
| Native file adapter and isolated data path | `lib/src/storage/store_io.dart` |
| Browser-local adapter | `lib/src/storage/store_web.dart` |
| Flutter notes list / editor | `lib/src/ui/notes_page.dart`, `editor_page.dart` |
| Read-only view, zoom, font runtime load, mobile orientation | `lib/src/ui/reader_page.dart` |
| Semantic modes and appearance | `lib/src/reader/reader_model.dart` |
| Version-1 reader.properties codec | `lib/src/reader/reader_preferences.dart` |
| Reader settings / Help | `lib/src/ui/settings_page.dart`, `help_page.dart` |
| AI spec stage gate | `scripts/spec_state.py`, `docs/ai/`, `docs/specs/active/...` |

## Important not-yet-verified details

The Flutter SDK and native toolchains were unavailable during packaging, so compilation, package resolution, analyzer, simulator, desktop rendering, pinch/trackpad behavior, orientation restoration, font dialogs and accessibility have not been verified. Generated host runners are created locally with `bash scripts/bootstrap.sh`. In particular, native font import, Windows file replacement, web storage and actual migration from KMP data should be explicitly tested before any production claim.
