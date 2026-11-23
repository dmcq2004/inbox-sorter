"""Copy config/sender-rules.yaml into the RULES block of SortBacklog.gs.

Run from the repo root:  python backlog/apps-script/build_rules.py
Rerun it whenever the sender rules change, before pasting the script into Apps Script again.
"""
import json
import pathlib
import re
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[2]
GS = ROOT / "backlog" / "apps-script" / "SortBacklog.gs"
PRIORITIES = {"Action", "NeedsDom", "FYI", "Bulk"}

rules = yaml.safe_load((ROOT / "config" / "sender-rules.yaml").read_text(encoding="utf-8"))["rules"]
out = []
for r in rules:
    if r["priority"] not in PRIORITIES:
        sys.exit(f"Unknown priority {r['priority']!r} for {r['match']}")
    item = {"match": r["match"], "priority": r["priority"], "folder": r.get("folder")}
    if r.get("archive") is not None:
        item["archive"] = r["archive"]
    if r.get("subject_override"):
        for p in r["subject_override"]:
            if p not in PRIORITIES:
                sys.exit(f"Unknown override priority {p!r} for {r['match']}")
        item["override"] = r["subject_override"]
    out.append(item)

body = "const RULES = [\n" + ",\n".join("  " + json.dumps(i, ensure_ascii=False) for i in out) + "\n];"
src = GS.read_text(encoding="utf-8")
new, n = re.subn(r"(// BEGIN RULES[^\n]*\n).*?(\n// END RULES)", lambda m: m.group(1) + body + m.group(2), src, flags=re.S)
if n != 1:
    sys.exit("RULES markers not found in SortBacklog.gs")
GS.write_text(new, encoding="utf-8")
print(f"{len(out)} rules written to {GS.relative_to(ROOT)}")
print("Folders used:", ", ".join(sorted({i['folder'] for i in out if i['folder']})))
