#!/usr/bin/env python3
"""Generate one read-only Aider task prompt from the MAIN-authored implementation plan."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

from spec_state import DEFAULT, ROOT, validate


def task(stage_id: str) -> str:
    data = validate(DEFAULT)
    selected = next((s for s in data['stages'] if s['id'] == stage_id), None)
    if selected is None:
        raise ValueError(f'Unknown stage: {stage_id}')
    if selected['status'] != 'in_progress':
        raise ValueError(f'Stage {stage_id} must be in_progress; it is {selected["status"]}')
    content = (ROOT / data['implementationPath']).read_text(encoding='utf-8')
    match = re.search(rf'<!-- BEGIN WORKER STAGE {re.escape(stage_id)} -->(.*?)'
                      rf'<!-- END WORKER STAGE {re.escape(stage_id)} -->', content, re.S)
    if not match:
        raise ValueError(f'Stage instructions missing: {stage_id}')
    template = (ROOT / 'docs/ai/WORKER_PROMPT_TEMPLATE.md').read_text(encoding='utf-8')
    return f'{template}\n\n## Assigned stage {stage_id}\n\n{match.group(1).strip()}\n'


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    try:
        content = task(args.stage)
    except ValueError as exc:
        print(f'Cannot prepare worker task: {exc}', file=sys.stderr)
        sys.exit(2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(content, encoding='utf-8')
        print(args.output)
    else:
        print(content)


if __name__ == '__main__':
    main()
