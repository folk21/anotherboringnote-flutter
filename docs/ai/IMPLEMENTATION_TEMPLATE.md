---
type: Implementation Template
title: MAIN-authored per-spec implementation plan
description: Template for converting one active specification into bounded, worker-safe implementation tasks.
---
# Implementation plan template

Create `docs/specs/active/subspecs/<slug>/implementation.md` **only after** a reviewed `spec.md` exists. This is an example structure to be customized by MAIN, not a general instruction to edit every referenced file.

```markdown
---
type: Implementation Plan
title: <spec title> implementation stages
description: Bounded, MAIN-owned worker instructions for <slug>.
---
# <spec title> implementation

## Initial repository state

- Inspected source/contract/tests: <actual paths>
- Already accepted behavior: <evidence>
- Unverified or outstanding behavior: <exact gaps>
- External decisions required: <if any>

## S01 — <bounded outcome>

<!-- BEGIN WORKER STAGE S01 -->
**Goal:** <one cohesive change>
**Read first:** <root/local AGENTS, spec, owner docs, contracts, tests>
**Allowed edits:** <focused paths>
**Tasks:** <concrete numbered implementation/check steps>
**Acceptance criteria:** <spec requirement IDs; objective behavior>
**Commands:** <focused deterministic tests; broader gate>
**Completion report:** <actual diff, commands, failures, manual gaps>
**Stop conditions:** <dependency changes, scope escalation, migrations>
<!-- END WORKER STAGE S01 -->

## S02 — <second outcome>

<!-- BEGIN WORKER STAGE S02 -->
<repeat explicit stage contract>
<!-- END WORKER STAGE S02 -->
```

MAIN must keep markers exactly aligned with all stage IDs in `STATE.json`. Every new stage gets a stable unique ID; changing the meaning of an accepted stage requires a new ID or explicit migration, not silent reuse. No stage is automatically accepted when the worker changes a file. Do not put secrets or unredacted personal content in worker instructions, evidence or model prompts.
