---
type: Development Workflow
title: MAIN and Aider WORKER workflow
description: Stage preparation, files, evidence gates, persistent JSON state, and Git-driven handoffs.
---
# Two-model spec-driven development

## Roles and canonical authority

**MAIN (ChatGPT / higher-capability model):** read current repository files; identify the owning active spec; design or revise normative `spec.md`; create a **stage-specific `implementation.md`** before assigning WORKER work; set allowed files and precise acceptance; validate worker report against actual code/tests; request human acceptance; update `STATE.json` through its validator; update stable docs/roadmap and archive only on acceptance.

**WORKER (currently Aider + a user-selected model, local or API):** work in a preselected **feature branch**, read repo map and approved context, implement exactly one bounded task described in `implementation.md`, run locally available checks, provide a concise actual evidence report. WORKER does not approve stages, push, merge, rewrite normative spec, edit `STATE.json`, or infer skipped tests passed. Aider is an editor, not an automatic spec state machine.

**Developer:** owns Git credentials, secrets, tools, approval and the final acceptance decision. Never place API tokens in repo. Python and Aider installation are workstation tools, not app runtime.

## Contract artifacts

For each active bounded spec under `docs/specs/active/subspecs/<slug>/`:

```text
spec.md            # Product intent and acceptance criteria (MAIN)
implementation.md  # Work packages, allowed scope and worker deliverables (MAIN)
STATE.json         # Machine-readable execution and acceptance state (MAIN/human)
evidence/          # Optional sanitized evidence files after local checks
```

See `docs/ai/IMPLEMENTATION_TEMPLATE.md` and `docs/ai/STATE_SCHEMA.md` for new-spec setup and machine-state structure. One machine-readable state file per active spec prevents hidden chat context or ad-hoc Aider sessions from becoming the source of truth. Status records are versioned and committed. `STATE.json` is **not** a log of every keystroke or an implementation checklist in prose.

## Stage lifecycle

1. MAIN reads root/local instructions, source code/tests/current docs and active spec.
2. MAIN prepares or updates a bounded stage in `implementation.md` with explicit start/end markers, requirements, allowed paths, preconditions, exact tests and report format.
3. Developer creates a clean feature branch, checks prerequisite stages accepted, and marks the stage `in_progress` with `scripts/spec_state.py start S03` (or re-queues a `verification_pending` stage for further work), **reviews and commits that state change** before launching Aider (the runner requires a clean working tree).
4. Developer invokes `bash scripts/aider_worker.sh S03 'openrouter/PROVIDER/MODEL'`. Aider receives read-only `--read` documents and generated message-file instructions for **one stage**. File selection is performed interactively using the repository map, with developer review of requested additions.
5. WORKER edits scoped files; developer checks `git diff`, runs focused and canonical validations, records an evidence file or PR link. With `--no-auto-commits`, no Aider commit is silently accepted.
6. MAIN/human records worker completion as `verification_pending`, then `verified` only with actual evidence, then `accepted` only after review using `scripts/spec_state.py`. No passed test == no verification claim.
7. Developer commits source, tests, evidence, reviewed state and docs on the branch, merges by chosen Git process. MAIN promotes the next stage or archives an entirely accepted spec.

For an already drafted stage at `verification_pending`, do **not** blindly run `start` again; first execute its missing checks or request a scoped corrective task from MAIN. No status is advanced solely because the worker says 'done'.

## Commands

```bash
python3 scripts/spec_state.py validate
python3 scripts/spec_state.py status
python3 scripts/spec_state.py start S03
git add docs/specs/active/subspecs/flutter-port-parity/STATE.json
git commit -m "chore: begin Flutter parity S03"
bash scripts/aider_worker.sh S03 'openrouter/PROVIDER/MODEL'
python3 scripts/spec_state.py worker-done S03
python3 scripts/spec_state.py verify S03 --evidence 'evidence/S03-device-smoke.md'
python3 scripts/spec_state.py accept S03 --evidence 'Reviewed PR #123 and device smoke evidence'
```

`start` checks accepted dependencies. `worker-done` means implementation is ready to test, **not** verified. `verify` attaches actual evidence and `accept` requires verified status and reviewed evidence. Use only commands matching the real situation. Stages S01/S02 start `verification_pending` because code exists but Flutter/device checks were not run; verify or correct them before S03.

### Aider setup and safety

Install Aider outside the repository using its official installation instructions (<https://aider.chat/docs/install.html>). Select a supported model through `AIDER_MODEL` or second script argument; for OpenRouter supply credentials through environment variables (never committed files). For local models, follow Aider/Ollama documentation and check performance on small edits. The provided script requires a Git feature branch and **clean worktree** and uses `--no-auto-commits`. It does not call `git push`, merge or amend.

Aider `--read` documents are read-only *context to Aider*, not a sandbox. Review actual diff for forbidden edits before committing. The WORKER might propose additional files through repo map; deny unrelated files. If an action requires broader changes, return control to MAIN and revise `implementation.md` first.

## Drift / recovery

Treat current checked-out repo files as truth after every Aider stage. Do not trust stale concatenated project snapshots or unmerged chat patches. If the user has applied several patches or edited files locally, refresh with a new complete repository archive. A status transition is reversible only by explicit review; do not rewrite acceptance history to conceal a failed check.

## Provenance

This workflow follows the user's requested MAIN → Aider WORKER → `implementation.md` → `STATE.json` design and incorporates available Aider stage-gating guidance. An up-to-date `signalharvester_files.txt` was not accessible in the provided attachments; see `docs/ai/PROVENANCE.md` before claiming an exact transplant of that file's conventions.
