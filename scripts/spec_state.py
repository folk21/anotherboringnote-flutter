#!/usr/bin/env python3
"""Validate or transition a MAIN-owned specification execution state."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT = ROOT / 'docs/specs/active/subspecs/flutter-port-parity/STATE.json'
STATUSES = {'ready', 'in_progress', 'verification_pending', 'verified', 'accepted', 'blocked'}
TRANSITIONS = {
    'start': {'ready': 'in_progress', 'blocked': 'in_progress'},
    'worker-done': {'in_progress': 'verification_pending'},
    'verify': {'verification_pending': 'verified'},
    'accept': {'verified': 'accepted'},
    'block': {
        'ready': 'blocked',
        'in_progress': 'blocked',
        'verification_pending': 'blocked',
        'verified': 'blocked',
    },
}


def validate(path: Path) -> dict:
    data = json.loads(path.read_text(encoding='utf-8'))
    if data.get('schemaVersion') != 1:
        raise ValueError('Unsupported STATE.json schemaVersion')
    if data.get('owner') != 'MAIN_AND_HUMAN':
        raise ValueError('Unexpected state owner')
    for key in ('specPath', 'implementationPath'):
        target = ROOT / data[key]
        if not target.is_file():
            raise ValueError(f'Missing {key}: {target}')
    implementation = (ROOT / data['implementationPath']).read_text(encoding='utf-8')
    stages = data.get('stages')
    if not isinstance(stages, list) or not stages:
        raise ValueError('At least one stage is required')
    ids = set()
    for stage in stages:
        sid = stage.get('id')
        if not isinstance(sid, str) or not re.fullmatch(r'S[0-9]{2,}', sid):
            raise ValueError(f'Invalid stage id: {sid}')
        if sid in ids:
            raise ValueError(f'Duplicate stage: {sid}')
        if stage.get('status') not in STATUSES:
            raise ValueError(f'Invalid status for {sid}')
        if not isinstance(stage.get('evidence'), list):
            raise ValueError(f'Evidence must be a list: {sid}')
        if stage['status'] in {'verified', 'accepted'} and not stage['evidence']:
            raise ValueError(f'Verification requires evidence: {sid}')
        if f'<!-- BEGIN WORKER STAGE {sid} -->' not in implementation or \
                f'<!-- END WORKER STAGE {sid} -->' not in implementation:
            raise ValueError(f'Implementation section missing: {sid}')
        if not isinstance(stage.get('dependsOn'), list):
            raise ValueError(f'Invalid dependencies for {sid}')
        if any(dep not in ids for dep in stage['dependsOn']):
            raise ValueError(f'Unknown/forward/self stage dependency: {sid}')
        ids.add(sid)
    return data


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['validate', 'status', *TRANSITIONS])
    parser.add_argument('stage', nargs='?')
    parser.add_argument('--evidence', help='Required verified or accepted evidence reference')
    parser.add_argument('--file', type=Path, default=DEFAULT)
    args = parser.parse_args()
    path = args.file.resolve()
    data = validate(path)
    if args.action == 'validate':
        print(f'Valid STATE.json: {path.relative_to(ROOT) if path.is_relative_to(ROOT) else path}')
        return
    if args.action == 'status':
        for stage in data['stages']:
            print(f"{stage['id']:4} {stage['status']:22} {stage['title']}")
        return
    if not args.stage:
        parser.error('Stage ID is required for a transition')
    stage = next((s for s in data['stages'] if s['id'] == args.stage), None)
    if stage is None:
        parser.error(f'Unknown stage: {args.stage}')
    current = stage['status']
    target = TRANSITIONS[args.action].get(current)
    if target is None:
        parser.error(f'Transition {args.action} is forbidden from {current}')
    if args.action == 'start':
        by_id = {s['id']: s for s in data['stages']}
        for dep in stage['dependsOn']:
            if by_id[dep]['status'] != 'accepted':
                parser.error(f'Dependency {dep} is not accepted')
    if args.action in {'verify', 'accept', 'block'} and not args.evidence:
        parser.error('--evidence is required for verify, accept and block')
    if args.evidence:
        stage['evidence'].append(args.evidence)
    stage['status'] = target
    stage['lastUpdatedBy'] = 'MAIN_OR_HUMAN'
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f"{args.stage}: {current} -> {target}; review and commit the updated STATE.json")


if __name__ == '__main__':
    main()
