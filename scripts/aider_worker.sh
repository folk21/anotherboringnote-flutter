#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

STAGE="${1:-}"
MODEL="${2:-${AIDER_MODEL:-}}"
if [[ -z "$STAGE" || -z "$MODEL" ]]; then
  echo 'Usage: bash scripts/aider_worker.sh S03 openrouter/PROVIDER/MODEL' >&2
  exit 2
fi
if ! command -v aider >/dev/null 2>&1; then
  echo 'Aider is not installed. Follow docs/ai/WORKFLOW.md.' >&2
  exit 2
fi
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo 'Start with a dedicated Git feature branch.' >&2
  exit 2
fi
BRANCH="$(git branch --show-current)"
if [[ -z "$BRANCH" || "$BRANCH" == 'main' || "$BRANCH" == 'master' ]]; then
  echo 'Refusing to run Aider on the default or detached branch.' >&2
  exit 2
fi
if [[ -n "$(git status --porcelain)" ]]; then
  echo 'Working tree must be clean before launching WORKER.' >&2
  exit 2
fi
mkdir -p .ai-runtime
python3 scripts/worker_task.py "$STAGE" --output .ai-runtime/worker-task.md

aider --model "$MODEL" --no-auto-commits --map-tokens 2048 \
  --read README.md --read AGENTS.md \
  --read docs/ARCHITECTURE.md --read docs/TESTS.md \
  --read docs/specs/active/subspecs/flutter-port-parity/spec.md \
  --read docs/specs/active/subspecs/flutter-port-parity/implementation.md \
  --read docs/specs/active/subspecs/flutter-port-parity/STATE.json \
  --message-file .ai-runtime/worker-task.md

echo 'Review git diff and actual validation before updating STATE.json.'
