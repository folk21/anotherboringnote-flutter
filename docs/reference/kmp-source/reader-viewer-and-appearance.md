---
type: Specification
title: Full-window reader, semantic modes, reflow zoom, orientation, and appearance
description: Active initial-product sub-spec for the read-only viewer, four reader modes, mobile orientation behavior, zoom, colors/fonts, and persistent reader preferences.
document_role: subspec
spec_status: active
parent: ../../active/spec-initial-functional-product.md
---
# Full-window reader, semantic modes, reflow zoom, orientation, and appearance

## Status

Active implementation focus, currently prioritizing Android device acceptance after Desktop implementation.

Desktop reader core, persistent colors/sizes/default mode, font presets, and custom font import are implemented in this active slice. Android pinch/orientation and system Back integration are available for device validation. Reader context is retained across transient Help/Settings navigation. Desktop modifier-wheel zoom is implemented; final live cross-platform acceptance remains open.

## Feature scope

- `READER.VIEW`;
- `READER.MODES`;
- `READER.ZOOM`;
- `READER.ORIENTATION`;
- `READER.APPEARANCE`;
- `SETTINGS.PERSISTENCE`;
- `PLATFORM.ANDROID`;
- `PLATFORM.DESKTOP`.

## Goal

Make a saved note useful as a large, simple reading/display surface for personal reading, low-vision reading, discreet nearby reading, and quickly showing text to another person.

Zoom enlarges typography and reflows the document rather than magnifying a rendered page.

## Requirement map

| Requirement | Feature ID | Purpose |
|---|---|---|
| RV-R1 | `READER.VIEW` | Dedicated full-window read-only viewer |
| RV-R2 | `READER.VIEW` | Conventional reader actions |
| RV-R3 | `READER.MODES` | Four semantic modes |
| RV-R4 | `READER.MODES` | Configurable semantic sizes |
| RV-R5 | `READER.MODES` | Private semantics |
| RV-R6 | `READER.MODES` | Normal semantics |
| RV-R7 | `READER.MODES` | Large semantics |
| RV-R8 | `READER.MODES`, `READER.ORIENTATION` | Presentation semantics |
| RV-R9 | `READER.MODES` | Default opening mode |
| RV-R10 | `READER.ZOOM` | Reflow zoom |
| RV-R11 | `READER.ZOOM` | Android interaction |
| RV-R12 | `READER.ZOOM` | Desktop interaction |
| RV-R13 | `READER.ZOOM` | Mode reset/default behavior |
| RV-R14 | `READER.ZOOM` | Reading-context stability |
| RV-R15 | `READER.ORIENTATION` | Default mobile orientation policy |
| RV-R16 | `READER.ORIENTATION` | Quick temporary mobile rotation |
| RV-R17 | `READER.ORIENTATION` | Presentation landscape lifecycle |
| RV-R18 | `READER.APPEARANCE` | Color presets/custom colors |
| RV-R19 | `READER.APPEARANCE` | Font presets/custom font |
| RV-R20 | `SETTINGS.PERSISTENCE` | Global reader preference persistence |
| RV-R21 | `READER.APPEARANCE` | App theme vs reader appearance |
| RV-R22 | `READER.VIEW` | Settings access |
| RV-R23 | `READER.VIEW` | Accessibility compatibility |
| RV-R24 | `READER.VIEW` | Presentation-only wrapping |
| RV-R25 | `SETTINGS.PERSISTENCE` | Failure-safe preference fallback |

## Requirements

### RV-R1 — dedicated read-only viewer

Opening a note displays a dedicated reader destination occupying the application content area.

The note list is replaced by the reader until the user navigates back. Desktop must follow the same conceptual model rather than automatically introducing a permanent master/detail split.

Reader text is not directly editable. The user enters editing through an explicit Edit action.

### RV-R2 — conventional reader actions

The reader exposes conventional navigation/actions appropriate to Compose/Material UI.

The primary action set includes Back/navigation, Edit, reader mode access, easy mobile rotation where applicable, and reader appearance/settings access.

Actions should use conventional top-app-bar/equivalent placement rather than custom floating controls without a product reason. Desktop must provide discoverable Help and a confirmed Delete action for the open note.

### RV-R3 — four semantic reader modes

The reader provides four directly selectable modes:

- Private;
- Normal;
- Large;
- Presentation.

Modes are shortcuts into useful reader states. They do not replace continuous zoom.

The user can switch modes while remaining in the current note.

Mode switching must not modify note content, reopen the editor, or unnecessarily reset the reading context. Brief navigation to Help/Settings and back should likewise preserve transient zoom, scroll and orientation; a new ordinary open starts from the configured default.

### RV-R4 — configurable semantic sizes

Private, Normal, and Large have user-configurable effective sizes.

Configuration must preserve:

```text
Private < Normal < Large
```

Exact supported ranges/steps belong to implementation/UX documentation after validation.

Presentation does not have a separate size: it uses the configured Large size.

### RV-R5 — Private mode

Private is intended for personal nearby reading with reduced legibility at a distance.

It uses the configured Private size.

It is a convenience/privacy-oriented presentation choice and must not be represented as a security guarantee or protection against shoulder surfing.

### RV-R6 — Normal mode

Normal is the ordinary reading mode.

It uses the configured Normal size and configured default mobile orientation policy.

### RV-R7 — Large mode

Large is intended for accessibility and distant personal reading.

It uses the configured Large size while preserving ordinary text reflow.

It must not stretch short content merely to force it to occupy the full physical screen.

### RV-R8 — Presentation mode

Presentation is optimized for showing text to another person, such as a phone number, address, or short phrase.

On mobile it must:

- use the configured Large size;
- enter landscape orientation while active;
- retain ordinary text rendering and reflow;
- avoid image-like fit-to-screen scaling.

On Desktop it uses the Large presentation state without rotating text or emulating mobile device orientation.

### RV-R9 — default opening mode

The user can configure which semantic mode is used when a note is opened normally.

Allowed values are Private, Normal, Large, and Presentation.

Changing mode temporarily while a note is open does not automatically change the global default.

The notes list may additionally expose `Open as …` through a conventional secondary action to enter a non-default mode directly without cluttering the primary tap/click action.

### RV-R10 — typographic/reflow zoom

Zoom changes effective reader typography/layout.

It must not implement normal zoom by scaling the completed reader surface as an image-like layer.

When zoom increases, glyphs become larger, line layout is recalculated, fewer characters fit per line, and text reflows to available width.

The maximum practical range must be substantially wider than ordinary UI font adjustment and useful for distant display, while remaining bounded/stable.

### RV-R11 — Android zoom interaction

Android supports pinch-to-zoom in the reader.

Normal one-finger vertical scrolling remains available.

Gesture handling must avoid interpreting ordinary scroll as unrelated commands.

### RV-R12 — Desktop zoom interaction

Desktop provides conventional zoom controls including platform-appropriate equivalents of:

```text
Ctrl/Cmd + Plus
Ctrl/Cmd + Minus
Ctrl/Cmd + 0
```

`Ctrl/Cmd + mouse wheel` or equivalent pointer/trackpad zoom should also be supported where practical.

Visible zoom/mode controls remain available; keyboard operation is not the only way to change size.

### RV-R13 — modes and continuous zoom

A semantic mode establishes a starting size.

After selecting a mode the user may continue zooming continuously.

Selecting a semantic mode again returns to that mode's configured size.

Transient continuous zoom does not automatically rewrite Private/Normal/Large configured sizes or the global default mode.

### RV-R14 — reading-context stability

Zooming/mode/orientation changes and brief visits to Help/Settings should preserve reading context where practical.

The implementation should avoid unnecessarily jumping to the beginning after each incremental change.

Exact anchoring mathematics is an implementation detail, but continuous use must remain stable enough for reading.

### RV-R15 — default mobile orientation policy

The mobile reader has a configurable default orientation policy:

- Follow system;
- Portrait;
- Landscape.

Private, Normal, and Large follow this policy unless a temporary reader override is active.

### RV-R16 — quick temporary mobile rotation

The mobile reader provides an easily reachable orientation action.

The user can change the current reader orientation without leaving the note or navigating through global Settings.

A temporary orientation override does not automatically modify the global default orientation preference.

### RV-R17 — Presentation landscape lifecycle

Presentation overrides the normal orientation policy with landscape while active on mobile.

Leaving Presentation restores the normal reader orientation policy/temporary state rather than leaving the app accidentally locked to landscape.

Orientation changes must preserve the current note/mode and reading context where reasonably avoidable.

### RV-R18 — reader colors

The application provides a small curated set of reader color presets covering at least ordinary light, dark, high contrast, and warm/sepia-style reading.

The user can also configure custom foreground/text and background colors.

Reader colors affect only presentation and never modify note content.

The UI should prevent/warn about effectively invisible text combinations where practical, but the initial product does not require a full accessibility contrast-analysis engine.

### RV-R19 — reader fonts

The application provides a small deliberate set of reader font choices covering at least sans-serif/general reading, serif, monospace, and a high-readability option where licensing/packaging permit.

The user can import/select a supported local font file for reader use.

The accepted font must be copied/imported into application-owned storage when durable platform ownership requires it.

If a configured custom font cannot be loaded, the reader falls back to a safe built-in font rather than making notes inaccessible.

The product must not bundle a large font catalog merely to increase the number of choices.

### RV-R20 — global persistent reader preferences

Reader appearance and reader defaults are global application settings in the initial product rather than per-note formatting.

Persisted settings include at least:

- Private/Normal/Large sizes;
- default opening mode;
- default mobile orientation policy;
- selected colors/preset;
- selected font/preset/custom-font reference as appropriate.

Reader settings are separate from note `.txt` files.

### RV-R21 — app theme and reader appearance are distinct

The ordinary app UI may follow Material/system light/dark behavior independently from the reader.

A user may use a light application shell with a dark/high-contrast reader or vice versa.

Reader colors must not require recoloring all application chrome.

### RV-R22 — settings access

A Settings action is reachable from ordinary application flow.

Reader settings expose semantic sizes, default mode, orientation policy, colors, fonts, and relevant reset/default behavior.

The reader may additionally provide a direct shortcut into its relevant settings section.

### RV-R23 — accessibility compatibility

Reader-specific zoom coexists with platform accessibility/font scaling rather than deliberately disabling it.

Controls retain appropriate touch/pointer target sizes and semantic labels.

Very large reader text must not make essential navigation controls permanently unreachable.

### RV-R24 — wrapping is presentation-only

The reader never persists generated line wrapping back into note text.

Changing window width, font, mode, zoom, or orientation may change visual line wrapping without changing note content.

### RV-R25 — failure-safe settings

Failure to load stored reader preferences/custom font falls back to a usable built-in appearance/default configuration.

Settings/custom-font failure must not prevent a valid note from opening.

## Failure semantics

Invalid persisted mode/size/orientation values must resolve to safe defaults rather than crashing the reader.

Invalid custom font data must not become the only usable font path.

A failed settings write must not be reported as persisted success.

Android orientation requests must be treated as platform effects coordinated with reader state; losing/recreating the host must not silently change note content or selected reader mode.

## Scenarios

### RV-S1 — normal open

A note opens in the configured default semantic mode and current global reader appearance.

### RV-S2 — Private reading

The user switches to Private. The configured small size is applied without any security claim.

### RV-S3 — large-distance reading

The user switches to Large and optionally pinches further. Text becomes very large, reflows, and remains vertically navigable.

### RV-S4 — show a phone number

The user selects Presentation on Android. The reader uses Large size and landscape; the phone can be turned toward another person without forcing arbitrary fit-to-screen stretching.

### RV-S5 — quick rotation

The user rotates the current reader with the visible in-reader action. The global default orientation setting remains unchanged.

### RV-S6 — Desktop keyboard zoom

The Desktop user changes zoom with conventional shortcuts and resets to the selected semantic/default size as defined by the UI action.

### RV-S7 — change appearance

The user switches a color/font preset or custom selection. Note text remains unchanged and settings survive restart.

### RV-S8 — custom font failure

A previously configured custom font cannot be loaded. The note still opens using a safe fallback font.

### RV-S9 — edit from reader

The user chooses Edit. The application navigates to the dedicated note editor rather than making reader text editable in place.

## Non-goals

This slice does not require image/page magnification, two-dimensional canvas panning, PDF-style fixed layout, Markdown/rich text, per-note themes/fonts, text-to-speech, teleprompter/autoscroll, annotations, bookmarks, permanent split-screen list/reader UI, or OS-level immersive fullscreen.

## Design constraints

- Reader semantics remain independent from note persistence.
- Text clarity/reflow are preferred over surface scaling.
- Semantic modes remain few and purpose-oriented.
- Large zoom remains bounded/stable.
- Appearance customization never mutates note content.
- Built-in presets remain deliberately small.
- Custom fonts fail safely.
- Android/Desktop interactions may differ while shared semantics remain aligned.

## Compatibility / migration

Reader preference storage must have an explicit schema/version strategy once persistence representation becomes compatibility-sensitive.

New optional settings should prefer backward-compatible defaults.

Removing/renaming a bundled font later must preserve deterministic fallback for previously persisted preferences.

## Validation

Deterministic common tests should cover semantic-size ordering, mode selection/reset behavior, zoom clamping, transient zoom vs persisted defaults, orientation-policy state, preference serialization, preset resolution, custom-color round-trip, and missing/invalid custom-font fallback.

Platform validation must additionally cover Android pinch zoom/scrolling, Android quick rotation/default policy, Presentation landscape/restore behavior, Desktop keyboard/pointer zoom, reader-to-editor navigation, settings persistence after restart, and usable appearance fallback after custom-font/settings failure.

Manual acceptance must confirm that very large text remains readable/reflowed rather than behaving like a magnified fixed page.
