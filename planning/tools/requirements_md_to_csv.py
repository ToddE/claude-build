#!/usr/bin/env python3
"""Builds a Jira-import CSV from functional-requirements.md when one is needed. The CSV is not kept.
The .md file is the only place requirements are edited. Run: python3 tools/requirements_md_to_csv.py"""
import csv, re, sys, pathlib
root = pathlib.Path(__file__).resolve().parent.parent
md = (root / 'functional-requirements.md').read_text().split('\n')
out = []
name = None
for line in md:
    m = re.match(r'\*\*Source:\*\* \[Use Case: (.*?)\]', line)
    if m:
        name = m.group(1)
    if line.startswith('| REQ-'):
        c = line[2:-2].split(' | ')
        assert len(c) == 7, line[:80]
        rid, req, comp, detail, acc, pri, src = c
        out.append({'Summary': req, 'Description': detail, 'Issue Type': 'Story', 'Priority': pri,
                    'Labels': rid.split('-')[1], 'Epic Link': '', 'Acceptance Criteria': acc, 'Source': f'{name}: {src}'})
dest = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else root / 'functional-requirements.csv'
with open(dest, 'w', newline='') as f:
    w = csv.DictWriter(f, fieldnames=['Summary', 'Description', 'Issue Type', 'Priority', 'Labels', 'Epic Link', 'Acceptance Criteria', 'Source'], lineterminator='\n')
    w.writeheader(); w.writerows(out)
print(len(out), 'rows written to', dest.name)
