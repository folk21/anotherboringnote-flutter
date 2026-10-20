---
type: Porting Matrix
title: KMP-to-Flutter contract mapping
description: Correspondence between frozen KMP feature ownership and new Flutter source with pending parity evidence.
---
# Porting matrix

| Original KMP concern | Flutter implementation | Verification required |
|---|---|---|
| `notes/NoteModel.kt` / `NoteManager.kt` | `lib/src/notes/note.dart`, `note_repository.dart` | Empty saves, duplicate, ordering, update timestamps |
| `notes/NoteIndexCodec.kt`, `PlainTextNoteStorage.kt` | `lib/src/notes/note_repository.dart` | Missing/malformed/future version, failure rollback, recovery |
| Desktop/Android file adapters | `lib/src/storage/store_io.dart` | Native Mac filesystem, Android/iOS private paths and permissions |
| Compose note list and editor | `lib/src/ui/notes_page.dart`, `editor_page.dart` | Draft/confirmations, keyboard/touch behavior |
| `reader/ReaderModel.kt` | `lib/src/reader/reader_model.dart` | Mode/zoom bounds and reset |
| `reader/ReaderPreferences.kt` | `lib/src/reader/reader_preferences.dart` | Byte-compatible `reader.properties`, future format handling |
| `reader/ReaderFeature.kt` | `lib/src/ui/reader_page.dart` | Focus, Ctrl/Cmd wheel/keyboard, pinch, layout reflow |
| Reader orientation adapters | Mobile `SystemChrome` in `reader_page.dart` | Presentation and temporary rotation restoration |
| KMP font importer/fallback | `settings_page.dart`, `reader_page.dart` | Platform dialogs, font loading, fallback |
| Compose app navigation | `lib/src/ui/app.dart` | Back navigation, settings return, edit handoff |
| KMP Help | `lib/src/ui/help_page.dart` | Reader instructions and access |
| Original KMP Gradle/AGENTS/SDD rules | Flutter `AGENTS.md`, `docs/specs/`, `docs/ai/`, `STATE.json` | Stage-gated developer acceptance |

This is a *mapping*, not a parity certification. Source snapshots are frozen in `docs/reference/kmp-source/` and active acceptance lives in the active spec.
