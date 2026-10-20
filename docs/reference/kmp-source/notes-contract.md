---
type: Module Contract
title: Notes capability contract
description: Stable ownership and dependency boundary for note management and portable note persistence.
---
# Notes capability contract

## Ownership

The notes capability owns:

- note identity/content/lifecycle semantics;
- create/update/duplicate/delete and ordering rules;
- editor draft/save/discard behavior;
- semantic storage contracts, persisted layout names, plus the shared plain-text storage orchestration;
- versioned technical metadata codec;
- shared list/editor Compose UI;
- feature-level note-opening, settings/help, and external edit-request handoff contracts.

## Dependency boundary

`:notes` must not depend on `:reader`, `:shared`, `:androidApp`, or `:desktopApp`.

Platform-specific filesystem APIs must not appear in common note code. `PlainTextNoteStorage` owns format reconciliation and mutation rollback; platform hosts implement only the narrow `PlainTextNoteFileStore` filesystem seam.

Reader behavior must not be implemented in this module. `notes` hands a `Note` to application composition through `onOpenNote`; composition/reader owns what happens next.

## Current invariants

- a note has no separate title;
- note content is plain Unicode text;
- application writes normalize logical line endings to `\n`;
- the list preview is derived from note content and is limited to two visual lines;
- note text is persisted as standalone UTF-8 `.txt` rather than only in a proprietary database;
- technical metadata stays separate from note text;
- version-1 metadata uses `formatVersion = 1` plus note IDs and Unix epoch-millisecond lifecycle timestamps;
- duplicate creates an independent note without modifying copied text;
- create/update/duplicate reject empty or whitespace-only content without mutating persisted notes;
- saving an empty new draft creates nothing, while saving an emptied existing draft requires explicit confirmation before normal deletion;
- ordinary ordering is `updatedAt` descending;
- platform/storage failures are explicit outcomes, not successful operations with hidden errors;
- an unsupported future metadata version must not be silently downgraded or rewritten.
