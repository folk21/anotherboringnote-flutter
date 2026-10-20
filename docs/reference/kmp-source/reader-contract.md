---
type: Module Contract
title: Reader capability contract
description: Stable ownership and dependency boundary for the full-window read-only viewer, appearance, font, and preference semantics.
---
# Reader capability contract

## Ownership

`:reader` owns:

- read-only viewer state/behavior;
- semantic reader modes and continuous typographic/reflow zoom;
- reader colors/font-selection semantics;
- reader-preference codec/storage contract;
- custom-font reference/fallback semantics;
- shared reader/settings UI;
- platform contracts needed for font import/resolution and later orientation integration.

`:reader` does not own note persistence or platform filesystem/dialog APIs.

## Dependency boundary

`:reader` must not depend on `:notes`, `:shared`, `:androidApp`, or `:desktopApp`.

The reader receives plain display text through composition. Platform hosts satisfy reader-owned seams for persistence/custom-font/orientation effects.

## Reader invariants

- zoom changes typography/layout, never scales a completed page-like surface;
- Private, Normal, Large, and Presentation are the only initial semantic modes;
- `Private < Normal < Large` for configured semantic sizes;
- Presentation uses Large size;
- transient zoom does not rewrite semantic sizes/default mode;
- reader appearance never mutates note text;
- built-in font selection remains usable when a custom font is unavailable;
- persisted custom-font references are app-owned filenames, not arbitrary filesystem paths;
- Desktop custom font import copies a validated `.ttf`/`.otf` into app-owned storage before it can become the persisted selection;
- Private mode is not a security guarantee;
- Desktop does not rotate text to emulate mobile Presentation orientation.

Android orientation effects are implemented through a reader-owned controller contract satisfied by the Android host. Presentation forces landscape; leaving the reader releases its orientation request. Manual rotation/lifecycle acceptance remains open.
