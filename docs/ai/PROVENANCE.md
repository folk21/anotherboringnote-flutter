---
type: Provenance Note
title: AI workflow reference provenance
description: Distinguishes the user's requested changes from unavailable SignalHarvester snapshot details.
---
# Workflow provenance and reconciliation

The user requested adoption of newer SignalHarvester conventions: separate MAIN and Aider WORKER, MAIN-generated per-spec implementation files, and explicit execution state in `STATE.json`. Those concrete requirements are implemented here.

During this conversion, the named `signalharvester_files.txt` file was **not present** in the accessible conversation/Project sources or personal Library listing. A personal Library `signalharvester-FULL.zip` snapshot dated September 2026 and separate Aider workflow guidance were available, but that older snapshot did not supply the newer STATE.json contract described by the user. Therefore this project's JSON field names, statuses and transition helper are a **new explicit design**, not a verified byte-for-byte copy of the newest SignalHarvester workflow.

Before extending the workflow, review the current SignalHarvester snapshot and reconcile: `STATE.json` field schema/locations, implementation file names, stage relationships, acceptance statuses, worker invocation/environment, allowed edits, reporting, archive policy and Git branch safeguards. Do not overwrite locally accepted state during reconciliation without an explicit migration. Current repository files remain authoritative until a reviewed spec changes them.
