---
type: Specification
title: Plain-text notes and portable local storage
description: Active initial-product sub-spec for the note model, list, CRUD, editor, and portable plain-text persistence.
document_role: subspec
spec_status: verification-pending
parent: ../spec-initial-functional-product.md
---
# Plain-text notes and portable local storage

## Status

Implementation complete; verification pending while the live Desktop workflow is exercised alongside reader integration.

Parent specification: [`../spec-initial-functional-product.md`](../spec-initial-functional-product.md).

Implementation was intentionally Desktop-first so the note model, editor workflow, storage format, and failure semantics could be exercised quickly in a live application. Shared note semantics remain KMP-owned, and Android compatibility remains part of final slice acceptance.

The reader sub-spec is now active. This slice owns only the feature-level note-open and edit-request handoffs; viewer rendering, semantic modes, zoom, appearance, and orientation remain `:reader` responsibilities composed above `:notes`.

## Feature scope

- `NOTES.MANAGEMENT`;
- `NOTES.EDITOR`;
- `STORAGE.PLAIN_TEXT`;
- `RUNTIME.OFFLINE_FIRST`.

## Goal

Provide the smallest complete local-note workflow:

```text
list → create/edit → save → list → open
```

while keeping every note's textual content independently readable as UTF-8 plain text.

## Requirement map

| Requirement | Feature ID | Purpose |
|---|---|---|
| NS-R1 | `NOTES.MANAGEMENT` | Minimal note model |
| NS-R2 | `STORAGE.PLAIN_TEXT` | Plain-text content files |
| NS-R3 | `STORAGE.PLAIN_TEXT` | Versioned technical index |
| NS-R4 | `STORAGE.PLAIN_TEXT` | Recoverable note content |
| NS-R5 | `STORAGE.PLAIN_TEXT` | Application-owned working storage |
| NS-R6 | `NOTES.MANAGEMENT` | Note creation |
| NS-R7 | `NOTES.MANAGEMENT` | Two-line list and open behavior |
| NS-R8 | `NOTES.EDITOR` | Draft/edit/save behavior |
| NS-R9 | `NOTES.MANAGEMENT` | Commit/timestamps |
| NS-R10 | `NOTES.MANAGEMENT` | Duplication |
| NS-R11 | `NOTES.MANAGEMENT` | Confirmed permanent deletion |
| NS-R12 | `STORAGE.PLAIN_TEXT` | Failure-safe publication |
| NS-R13 | `STORAGE.PLAIN_TEXT` | Platform storage boundary |
| NS-R14 | `STORAGE.PLAIN_TEXT` | Stable time representation |
| NS-R15 | `STORAGE.PLAIN_TEXT` | No database requirement |

## Requirements

### NS-R1 — minimal persistent model

The conceptual note model contains:

```text
Note
    id
    content
    createdAt
    updatedAt
```

There is no separate title in the initial product.

`id` is an opaque stable identifier whose persisted representation is filename-safe and does not encode mutable user content.

### NS-R2 — text is the note content

The proposed storage layout is:

```text
abn-data/
    index.json
    notes/
        <note-id>.txt
        ...
```

`notes/<note-id>.txt` contains only the user's note text and no ABN metadata header.

The application must not insert an artificial title, YAML frontmatter, JSON metadata, or formatting markers required only by ABN.

Text uses UTF-8. Logical line endings should be persisted canonically so Android and Desktop do not create different note semantics.

### NS-R3 — versioned technical index

`index.json` owns the format version and lifecycle metadata needed by the initial product.

The initial format version is `1`.

Conceptual example:

```json
{
  "formatVersion": 1,
  "notes": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "createdAtEpochMillis": 1791270000000,
      "updatedAtEpochMillis": 1791270600000
    }
  ]
}
```

The index must not contain a second copy of full note content.

### NS-R4 — text remains recoverable

The `.txt` files are the authoritative human-readable note content.

A missing/damaged metadata index must not justify deleting otherwise readable note text.

The implementation should keep enough separation between content/index handling that future recovery/reconciliation can be added without converting text files to another format.

### NS-R5 — application-owned working storage

Android and Desktop initially store working note data under application-owned local storage.

The user must not be required to select and permanently manage a live external directory merely to use ABN.

Future export/import may copy/package the documented storage format through platform file pickers.

### NS-R6 — note creation

Creating a note opens the editor with a new draft.

The note receives a stable identity no later than the first successful commit.

Creating one note must not modify another note.

Saving an empty or whitespace-only new draft must not create a note or write a content/index entry; the editor may return to the list without persisting anything.

### NS-R7 — note list and open behavior

The list orders notes by `updatedAt` descending.

Each row displays no more than two visual lines derived from note content.

The row body is the primary open action and must emit the selected note through the feature-level open handoff. Application composition/reader will later interpret that handoff using the configured default reader mode. This slice must not implement reader rendering merely to satisfy the handoff.

The compact UI must not expose a permanent row of Edit/Duplicate/Delete buttons. Secondary actions belong in a conventional overflow/context surface. Desktop may additionally provide an appropriate context menu.

### NS-R8 — editing and drafts

The editor operates on a draft separate from the last committed note state until Save/commit succeeds.

The initial product uses an explicit Save action. Desktop additionally supports the conventional save shortcut where applicable.

Navigating away with changed, uncommitted text must not silently discard the draft. The user must receive a deterministic choice to continue editing or discard changes.

Saving an existing note whose draft has become empty or whitespace-only must first display: "The note is empty and will be removed. Continue?" Cancel keeps the draft and original note; confirmation invokes normal note deletion. A failed delete must leave the editor open and original persisted note intact. Direct note create/update/duplicate calls must not persist empty content.

Autosave may be considered later but is not required by this slice.

### NS-R9 — successful commit

A successful commit updates note content and `updatedAt` while preserving note identity and `createdAt` for an existing note.

A failed storage operation must not be represented as a successful save.

### NS-R10 — duplication

Duplicate creates a new note containing exactly the current committed text of the source note.

The duplicate receives a new identity, `createdAt`, and `updatedAt`. The source note remains unchanged.

The implementation must not insert labels such as `Copy` into duplicated user content.

### NS-R11 — deletion

Delete is destructive and requires explicit confirmation before permanent deletion.

After confirmed successful deletion, the note no longer appears in the ordinary list.

Trash/recycle-bin persistence is not part of this slice.

### NS-R12 — persistence consistency

Storage updates must minimize the risk of partially written notes/index state.

Platform adapters should use temporary-write/replace or another appropriate atomic publication strategy where available.

The UI must not report successful persistence before platform storage completes successfully.

Cancellation must not be translated into successful persistence.

### NS-R13 — storage contract boundary

`:notes` owns semantic storage contracts.

Android/Desktop hosts own concrete filesystem implementation.

Common note code must not depend on Android or JVM filesystem classes.

### NS-R14 — time representation

The version-1 index persists `createdAtEpochMillis` and `updatedAtEpochMillis` as non-negative Unix epoch milliseconds.

This representation is unambiguous and timezone-independent. Any future localized display formatting is presentation behavior and does not change storage semantics.

### NS-R15 — no database requirement

The initial note capability must not require Room, SQLDelight, SQLite, Realm, or another database engine.

A database may be introduced only through a future active specification demonstrating a concrete requirement that the text/index model cannot reasonably satisfy.

## Failure semantics

A failed save preserves the in-memory draft so the user can retry or copy the text.

A failed duplicate must not create a visible phantom note.

A failed delete leaves the note visible.

Expected platform/storage failures must cross the capability boundary as explicit failure outcomes rather than raw platform exception wording becoming a stable user-facing contract.

## Scenarios

### NS-S1 — create

The user creates a note, enters several lines, saves it, and returns to the list. The list shows at most the first two visual lines.

### NS-S2 — edit

The user edits an existing note and saves it. Identity/creation time remain unchanged; ordering follows the new `updatedAt`.

### NS-S3 — discard warning

The user modifies text and attempts to leave without saving. The application does not silently lose the draft.

### NS-S4 — duplicate

The user duplicates a note and edits the copy. The original remains unchanged.

### NS-S5 — delete

The user selects Delete, confirms, and the note is permanently removed after successful persistence.

### NS-S6 — inspect outside ABN

A developer or future export tool opens `notes/<id>.txt` with an ordinary UTF-8 text reader and sees note content without ABN-specific parsing.

## Non-goals

This slice does not require titles, folders, tags, search, Markdown, attachments, note history, trash, synchronization, encryption, export/import UI, filesystem watching, or concurrent multi-process editing.

## Design constraints

- Keep note content portable and unpolluted by application metadata.
- Keep platform APIs outside common note logic.
- Prefer direct explicit storage contracts over a database abstraction designed for hypothetical future complexity.
- Preserve deterministic save/delete/duplicate outcomes.

## Compatibility / migration

The initial persisted format is version `1`.

Future incompatible changes require explicit migration behavior.

A future richer feature must not silently replace `.txt` content with a proprietary encoded representation.

## Validation

Acceptance requires deterministic tests for create/load/edit/duplicate/delete/order, stable identity, timestamp preservation/update, UTF-8 round-trip, index serialization/deserialization, storage failure propagation, and Android/Desktop adapter compatibility with the same semantic storage contract.

Manual/integration acceptance must additionally demonstrate that a persisted note can be opened as ordinary text outside ABN.


## Implementation tasks

Remaining acceptance work for this active slice:

- run the Gradle/KMP and Desktop integration tests in an environment with the configured Gradle distribution available;
- exercise Desktop create/edit/save/duplicate/delete and restart persistence manually;
- exercise the shared notes UI and Android app-private storage on Android before final slice acceptance;
- verify the note-row primary open handoff in the live app; the temporary shared integration notice is replaced by reader navigation only after the reader sub-spec becomes active.
