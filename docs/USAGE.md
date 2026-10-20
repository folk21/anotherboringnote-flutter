---
type: Usage Guide
title: Local interaction and developer usage
description: Notes/reader interaction, isolated datasets, platform commands, and compatibility cautions.
---
# Usage

## Notes

Start with New note, type plain text, and Save. Empty new content is not persisted. Tap/click a note to open the read-only reader. Open its actions menu to edit, duplicate, or delete. Deletion is final and must be confirmed. Exiting the editor with changes prompts to discard; an empty saved existing note is explicitly confirmed for deletion.

Each note is one UTF-8 `.txt` file on native platforms. The two-line list preview is derived from note content, not a title field. Recent edits appear at the top.

## Reader

Reader modes: Private (14sp), Normal (24sp), Large (56sp), Presentation (Large size plus mobile landscape orientation). Sizes are configurable in Settings, with `Private < Normal < Large`. Private mode is only a readability preference, not security.

Zoom with +/−/Reset, Ctrl/Cmd + plus/minus/0, pointer Ctrl/Cmd + wheel on desktop, and pinch on supported touch devices. Reader changes font size and line wrapping; it does not change saved text or configured mode sizes. Settings allow preset/custom foreground and background colors, font presets and TTF/OTF import into app storage. Font import and platform dialog acceptance remain pending until live verification.

The Reader and editor are separate views. Reader has no direct text editing. Mobile orientation follows the configured policy except Presentation, which forces landscape; orientation is released when leaving the reader.

## Developer commands

```bash
bash scripts/bootstrap.sh
flutter devices
flutter run -d chrome
flutter run -d macos
flutter test
bash scripts/run_checks.sh
python3 scripts/spec_state.py status
```

To avoid cluttering or damaging existing data:

```bash
ABN_DATA_DIR=abn-flutter-scratch flutter run -d macos
```

## Native data and KMP interop

New Flutter macOS data: `getApplicationSupportDirectory()/AnotherBoringNoteFlutter/abn-data` (inside the app-specific macOS sandbox container). A relative `ABN_DATA_DIR` stays in that container; `/tmp` and other absolute directories may be denied by App Sandbox. Previous KMP macOS data: `~/Library/Application Support/AnotherBoringNote/abn-data`. Back up both roots before attempting a manual copy. Both use the version-1 `index.json`, `notes/`, `settings/reader.properties` and `fonts/` layout, but **cross-implementation migration has not been verified**. Copy into an isolated scratch directory and inspect results, never directly share live data roots with both apps at once. Web storage is **not** filesystem-compatible.

## No service dependencies

The app needs no authentication, remote server, cloud sync, database or AI service. Aider is a **developer tool only** and is not part of the app runtime.
