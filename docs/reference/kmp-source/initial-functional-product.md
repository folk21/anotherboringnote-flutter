---
type: Specification
title: Another Boring Note initial functional product specification
description: Active umbrella specification for the initial offline plain-text notes product on Android and Desktop.
document_role: umbrella
spec_status: active
current_focus: subspecs/reader-viewer-and-appearance.md
---
# Another Boring Note initial functional product specification

## Status

Active umbrella specification for the initial functional product.

Current implementation focus:

- [`subspecs/reader-viewer-and-appearance.md`](subspecs/reader-viewer-and-appearance.md).

Reviewed follow-up slices:

- [`subspecs/plain-text-notes-and-storage.md`](subspecs/plain-text-notes-and-storage.md) — implementation complete, live verification pending.

Completing one sub-spec does not complete this umbrella. The umbrella is complete only when Android and Desktop provide the accepted note-management, storage, editor, reader, reader-mode, orientation, appearance, preference, and validation behavior defined here.

## Product intent

Another Boring Note is a deliberately small offline-first text-note application.

The application is optimized for two primary tasks:

1. capture and edit simple plain-text notes with minimal interaction overhead;
2. open a note as a highly readable full-window text surface that can quickly switch between discreet personal reading, normal reading, large accessibility reading, and showing text to another person.

The product should remain understandable without documentation and should prefer conventional Compose Multiplatform / Material interaction patterns over novel UI.

The reader is the distinguishing capability. Organization, formatting, collaboration, cloud features, and spatial canvases are deliberately outside the initial product.

## Feature scope

- `RUNTIME.OFFLINE_FIRST`;
- `NOTES.MANAGEMENT`;
- `NOTES.EDITOR`;
- `STORAGE.PLAIN_TEXT`;
- `READER.VIEW`;
- `READER.MODES`;
- `READER.ZOOM`;
- `READER.ORIENTATION`;
- `READER.APPEARANCE`;
- `SETTINGS.PERSISTENCE`;
- `PLATFORM.KMP`;
- `PLATFORM.MODULAR_KMP`;
- `PLATFORM.ANDROID`;
- `PLATFORM.DESKTOP`;
- `TESTING.DETERMINISTIC_LOCAL`.

Feature identifiers are defined in `docs/FEATURES.md`.

## Goal

Deliver a compact Compose Multiplatform application that allows a user to:

- view a list of local text notes;
- create, open, edit, duplicate, and delete a note;
- read a note in a dedicated full-window read-only viewer;
- open/switch the viewer among Private, Normal, Large, and Presentation modes;
- configure the semantic sizes used by Private, Normal, and Large;
- continue zooming continuously after selecting a semantic mode;
- configure default opening mode and mobile orientation behavior;
- rotate the mobile reader quickly without leaving the note;
- use Presentation mode to show text to another person in landscape on mobile;
- customize reader foreground/background colors and fonts;
- retain notes and reader preferences across application restarts;
- use the same conceptual product on Android and Desktop.

All core note and reader behavior must remain usable without network access or a backend.

## Requirement map

| Requirement | Feature ID | Purpose |
|---|---|---|
| R1 | `RUNTIME.OFFLINE_FIRST` | Offline local-first behavior |
| R2 | `NOTES.MANAGEMENT` | Minimal note model |
| R3 | `NOTES.MANAGEMENT` | Note list and two-line preview |
| R4 | `NOTES.MANAGEMENT` | Note lifecycle operations |
| R5 | `NOTES.EDITOR` | Plain-text editor |
| R6 | `READER.VIEW` | Dedicated read-only reader |
| R7 | `READER.MODES` | Four semantic reader modes |
| R8 | `READER.ZOOM` | Continuous reflow zoom |
| R9 | `READER.ORIENTATION` | Default and temporary mobile orientation behavior |
| R10 | `READER.APPEARANCE` | Reader colors and fonts |
| R11 | `STORAGE.PLAIN_TEXT` | Portable text storage |
| R12 | `SETTINGS.PERSISTENCE` | Persistent reader/application preferences |
| R13 | `PLATFORM.KMP`, `PLATFORM.ANDROID`, `PLATFORM.DESKTOP` | Shared Android/Desktop product |
| R14 | `PLATFORM.MODULAR_KMP` | Explicit extensible module boundaries |
| R15 | `TESTING.DETERMINISTIC_LOCAL` | Repeatable validation |
| R16 | `PLATFORM.MODULAR_KMP` | Extensibility without premature plugin infrastructure |

## Requirements

### R1 — offline-first operation

Core note management, editing, reading, reader-mode switching, zooming, orientation behavior, and reader customization must work without network access.

The initial product must not require an account, authentication, a remote backend, cloud synchronization, or an Internet connection.

Network functionality must not become an implicit dependency of startup or ordinary note access.

### R2 — minimal note model

A note is fundamentally plain text.

The initial user-visible note model must not require a separate title.

Persistent note state contains only information needed for identity, text content, and lifecycle metadata.

Folders, tags, favorites, colors, coordinates, formatting mode, synchronization state, attachment state, and other organization/product fields must not be added preemptively.

### R3 — note list

The normal application entry surface displays the user's notes as a list.

Each row must show at most two visual lines derived from note content. Overflow must not enlarge the row indefinitely.

The default ordering must place the most recently changed notes first.

Opening a row opens the note in the configured default reader mode, not directly in editing mode.

The compact list must not expose a permanent row of Edit/Duplicate/Delete buttons for every note. Secondary operations should use conventional overflow/context actions. Those actions should be visibly discoverable, not dependent on an unlabeled glyph alone.

### R4 — note lifecycle operations

The user must be able to create, open, edit, duplicate, and delete a note.

Duplicating creates an independent note with a new stable identity, the same committed text content at duplication time, and independent lifecycle timestamps.

The implementation must not modify duplicated text by automatically adding labels such as `Copy`.

Deletion is permanent in the initial product after explicit destructive-action confirmation. Trash/recycle-bin history and note version history are not required by this umbrella.

### R5 — plain-text editor

Editing uses a dedicated plain-text editor surface without rich-text formatting controls.

The editor must preserve ordinary Unicode text and line breaks.

The initial product uses an explicit Save/commit action. Desktop should additionally support the conventional save keyboard shortcut. Saving an empty new draft must not create a note. Saving a cleared existing note requires explicit deletion confirmation rather than silently overwriting its text with empty content.

Leaving the editor with changed, uncommitted text must not silently discard the draft.

### R6 — dedicated reader

Opening a note displays a dedicated read-only reader destination occupying the application content area.

The list must not remain permanently visible beside the reader merely because a Desktop window is wide.

The user must be able to return to the list and enter editing mode through explicit controls.

Ordinary reader interaction must not modify note content.

### R7 — semantic reader modes

The reader provides four directly selectable semantic modes:

- Private;
- Normal;
- Large;
- Presentation.

Private, Normal, and Large are user-configurable semantic sizes rather than hard-coded typography constants.

Configured semantic sizes must preserve `Private < Normal < Large`.

Presentation uses the configured Large size rather than a separate fourth font-size setting.

Private mode is intended to reduce readability at a distance for nearby personal reading. It is a presentation/privacy convenience and must not be represented as a security guarantee.

Large mode is intended for accessibility and distant personal reading. It must not stretch short text merely to force it to occupy the full physical screen.

Presentation mode is optimized for showing text to another person. On mobile it uses the configured Large size and landscape orientation while active.

The user can configure which semantic mode is used for ordinary note opening.

A note may also be opened into a non-default semantic mode through a conventional secondary action where that improves speed without cluttering the primary list interaction.

### R8 — continuous typographic/reflow zoom

Reader zoom is typographic/reflow zoom, not image/page magnification.

Increasing zoom enlarges rendered text and recalculates line wrapping for the available reader width.

The normal model remains:

> larger text → fewer characters per line → reflow → vertical navigation through the text.

The reader must not implement ordinary zoom by scaling the completed content surface as a bitmap-like layer or by introducing an infinite canvas.

After opening/selecting a semantic mode, the user may continue changing the size through touch, keyboard, pointer, or visible zoom controls as appropriate to the platform.

Selecting a semantic mode again returns the reader to that mode's configured size.

Transient zoom changes do not automatically rewrite the configured semantic sizes or global default mode.

### R9 — mobile orientation behavior

The mobile reader has a configurable default orientation policy:

- Follow system;
- Portrait;
- Landscape.

Private, Normal, and Large use that policy unless the user applies a temporary in-reader orientation override.

The reader must provide an easy-to-reach mobile orientation action so the user can rotate the current reading surface without leaving the note or navigating through global Settings.

A temporary orientation override must not automatically change the global default orientation setting.

Presentation overrides the normal policy with landscape orientation on mobile while Presentation is active.

Leaving Presentation must restore the normal reader orientation policy/temporary state rather than accidentally leaving the application permanently locked to landscape.

Orientation changes must not lose the current note, current semantic mode, or reading context where reasonably avoidable.

Desktop must not rotate rendered text or emulate a mobile device orientation. Presentation on Desktop uses the Large presentation state without synthetic 90-degree text rotation.

### R10 — reader appearance

Reader foreground/background colors are configurable independently from the ordinary application Material theme.

The product must provide a small curated set of useful built-in color combinations, including ordinary light, dark, high-contrast, and warm/sepia-style reading, plus custom foreground/background colors.

The product must provide a small deliberate set of reader font choices and support a custom user-provided reader font.

Custom font failure must fall back to a safe built-in font rather than making valid notes unreadable.

Appearance is global reader preference in the initial product rather than per-note formatting.

Changing reader appearance must not modify note text.

### R11 — portable text storage

Note text must be stored as UTF-8 plain text in a simple documented format.

Individual note content must remain recoverable with ordinary text-processing tools without requiring an ABN-specific database engine.

Technical metadata required for identity and ordering may use a small versioned machine-readable companion format, but it must not contain the only copy of note text.

The initial storage format must make future export/import possible without converting ordinary note text into a proprietary representation.

### R12 — persistent reader/application preferences

Reader semantic sizes, default opening mode, mobile orientation policy, appearance, and other accepted reader-default settings must survive application restart.

Mutable application preferences remain separate from note text.

A settings/custom-font failure must not make otherwise valid note text unreadable when safe defaults can be used.

### R13 — Android and Desktop

The initial supported targets are Android and Desktop JVM through Compose Multiplatform.

Common product behavior and reusable Compose UI should live in KMP common code when no platform-specific ownership is required.

Android and Desktop may use different platform adapters/input mechanisms while preserving common semantics.

The architecture should avoid unnecessarily blocking a future iOS target, but iOS support is not part of initial acceptance.

### R14 — modular KMP architecture

The repository must establish explicit acyclic Gradle module boundaries before substantial feature implementation.

Modules represent meaningful capability/platform ownership rather than technical layer names created without current need.

The initial architecture keeps note management and reader behavior independently owned.

Platform filesystem, Android orientation, Android lifecycle, and Desktop window/filesystem APIs must not leak into common feature code.

### R15 — deterministic validation

Core note/storage/reader state behavior must be testable without public network access, production credentials, external services, or manual UI interaction.

Platform-specific build/interaction validation may supplement common deterministic tests where necessary.

The repository must define one documented canonical local validation entry point.

### R16 — extensibility without premature plugin infrastructure

The architecture must allow later capabilities such as search, import/export, synchronization, encryption, Markdown rendering, or additional reader behavior behind explicit module boundaries.

The initial product must not implement dynamic plugin discovery, runtime class loading, extension marketplaces, generic extension registries without a consumer, or abstract plugin APIs created only for hypothetical future requirements.

The initial extensibility model is compile-time modularity with small explicit public contracts.

A runtime plugin system requires a separate future specification and concrete use cases.

## Scenarios

### S1 — create and read a note

The user starts ABN, creates a note, enters text, saves it, returns to the list, and opens the note.

The note opens in the configured default semantic reader mode.

### S2 — discreet personal reading

The user opens/selects Private mode.

The reader uses the configured Private size, making the text less convenient to read from a distance while preserving ordinary local readability. The UI does not claim this is a security barrier.

### S3 — ordinary reading

The user opens/selects Normal mode.

The reader uses the configured Normal size and normal configured orientation policy.

### S4 — large accessibility reading

The user opens/selects Large mode and optionally zooms further.

Text becomes substantially larger, reflows to the current width, and remains readable by scrolling through the document.

A one-line phone number remains ordinary text at the configured Large/zoom size rather than being forcibly stretched to fill every pixel of the screen.

### S5 — show text to another person

The user opens/selects Presentation mode on an Android phone.

The reader uses the configured Large size and landscape orientation so the device can be turned toward another person, for example to show a phone number, address, or short phrase.

Leaving Presentation restores the normal orientation policy/state.

### S6 — quick temporary rotation

The user is reading a note in Private, Normal, or Large mode and invokes the visible orientation action.

The current reader rotates without leaving the note and without changing the global orientation default.

### S7 — duplicate a note

The user duplicates an existing note.

The list contains a second independent note with identical content. Editing either note afterward does not change the other.

### S8 — change reader appearance

The user selects another reader color preset and font.

The open reader updates without changing note text. After application restart, the selected settings remain active.

### S9 — offline restart

The user closes and restarts ABN while no network is available.

Previously saved notes and reader settings remain available.

### S10 — same conceptual workflow on Desktop

A Desktop user performs the same create → edit → list → read flow using appropriate mouse/keyboard interaction.

Presentation mode uses the Large presentation state but does not rotate text as though the Desktop display were a phone.

## Non-goals

The initial functional product does not require:

- folders/notebooks;
- tags;
- favorites/pinning;
- full-text search;
- Markdown editing/rendering;
- WYSIWYG/rich text;
- attachments/images/drawing;
- checklists;
- reminders/widgets;
- collaboration/accounts/cloud synchronization;
- note history/trash;
- encryption;
- automatic AI functionality;
- an infinite canvas or spatial note coordinates;
- image/page magnifier behavior;
- runtime plugins;
- a web target;
- iOS delivery.

These capabilities require later explicit specifications if selected.

## Design constraints

- Simplicity is a product requirement, not merely an implementation preference.
- User note text must remain portable.
- The reader is a first-class capability, not an editor with disabled input.
- Reader zoom must preserve text reflow.
- Semantic reader modes provide quick useful starting states but do not replace continuous zoom.
- Private mode must not be presented as a security guarantee.
- Material/Compose conventions should be preferred where they fit the product.
- Responsive behavior should primarily follow available window size and input model rather than duplicate complete Android/Desktop UIs.
- Platform APIs belong to platform adapters.
- Public module APIs should remain small.
- New abstractions require an actual boundary, variation point, lifecycle owner, or test seam.

## Compatibility / migration

The initial persisted note format starts at format version `1`.

Once user data exists, incompatible changes to note-storage semantics require explicit compatibility/migration behavior.

Adding application features must not silently rewrite ordinary note text into a richer proprietary representation.

Persisted reader preferences should use backward-compatible defaults when optional settings are added later.

## Validation

Initial umbrella acceptance requires evidence that:

1. canonical deterministic repository checks pass;
2. common note-management and reader-state tests pass;
3. the Desktop application builds and primary flows are exercised;
4. the Android application builds and primary flows are exercised;
5. persisted notes survive restart on both supported platforms;
6. stored `.txt` content can be inspected independently from ABN;
7. reader reflow zoom works through intended Android/Desktop inputs;
8. Private/Normal/Large/Presentation mode switching works;
9. configured semantic sizes/default mode survive restart;
10. Android default/temporary orientation behavior works;
11. Android Presentation enters landscape and restores normal orientation behavior on exit;
12. reader appearance/custom-font fallback survives restart/failure safely.

Exact commands belong in `docs/TESTS.md`.

## Implementation tasks

1. Preserve the accepted KMP project/module/documentation foundation.
2. Close live verification of the implemented plain-text notes/storage slice.
3. Implement and validate reader/viewer/modes/orientation/appearance, Desktop first and Android refinement afterward.
4. Perform cross-platform umbrella acceptance.
5. Move accepted behavior into owning current-state docs.
6. Archive the umbrella only after the complete product target is accepted.
