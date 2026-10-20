---
type: Specification Guide
title: Specification lifecycle and stage artifacts
description: Authoritative spec/implementation/STATE.json lifecycle for MAIN and WORKER roles.
---
# Specification lifecycle

## Hierarchy

```text
docs/specs/
  active/
    spec-initial-functional-product.md
    subspecs/
      flutter-port-parity/
        spec.md                # MAIN-owned normative change contract
        implementation.md      # MAIN-owned bounded stage instructions
        STATE.json             # MAIN/human-owned machine-readable stage state
  planned/subspecs/
  archive/subspecs/
```

A bounded sub-spec uses a **directory** because three different artifacts have different authority:

- `spec.md` states requirements, acceptance criteria, compatibility and non-goals; it is not an implementation log.
- `implementation.md` is generated/refined by the **MAIN model** before assigning a worker stage: scope, exact work order, allowed files, validation, output contract, stopping rules. Worker reads it as authoritative task guidance, not a self-approval artifact.
- `STATE.json` contains canonical state for every stage, dependencies, evidence and last reviewer. It is machine validated. Worker does **not** update it. Neither completion claims in chat nor commits equal acceptance.

Normative product feature IDs belong to `docs/FEATURES.md`; lifecycle/current-status summaries belong to `docs/ROADMAP.md`; accepted behavior belongs to current-state documents; `docs/ai/WORKFLOW.md` owns agent interactions.

## Status values

`ready` → `in_progress` → `verification_pending` → `verified` → `accepted`, with `blocked` for unresolved failures. Transition rules and CLI are implemented in `scripts/spec_state.py`. Only MAIN/developer can change state, on a dedicated Git branch after reviewing actual work and evidence. A Stage may be `verification_pending` without tests being run: it means implementation was produced, **not** that it passed verification.

## Lifecycle rules

Use `active/` for the one bounded current implementation focus, `planned/` for approved future scope, and `archive/` only after human acceptance and current-state doc updates. Move rather than duplicate a completed spec; keep its final spec, implementation, state and evidence together. Never silently replace a spec's requirements with the worker's assumptions.

## Initial active spec

`active/spec-initial-functional-product.md` is the Flutter-specific umbrella; `active/subspecs/flutter-port-parity/` carries the current conversion and acceptance work. Historical KMP contracts under `docs/reference/kmp-source/` are snapshots for parity review, not active Flutter instructions.
