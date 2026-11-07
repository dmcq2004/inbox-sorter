"""Read a Microsoft Sway newsletter as plain text, with no browser needed.

Sway pages are rendered by JavaScript, but the page loads its content from one
public endpoint, POST https://sway.cloud.microsoft/s/<id>/get, which returns the
whole story as (gzipped) JSON. This script calls that endpoint and rebuilds the
text in reading order.

Usage:
    python -I school/tools/read_sway.py <sway url or id> [...]          # full text
    python -I school/tools/read_sway.py --dates <sway url or id> [...]  # just the "Important Dates" list
    python -I school/tools/read_sway.py --save school/newsletters <url>  # also write <dir>/<title>.txt

Standard library only. Read-only: it fetches public newsletter pages and nothing else.
"""
from __future__ import annotations

import argparse
import gzip
import json
import re
import sys
import urllib.request
from pathlib import Path

ENDPOINT = "https://sway.cloud.microsoft/s/{id}/get?currentClientVersion=201"
ID_RE = re.compile(r"(?:sway\.(?:cloud\.microsoft|office\.com)/(?:s/)?)?([A-Za-z0-9]{12,20})(?:[/?#].*)?$")
DATES_START = re.compile(r"^\s*(important dates|upcoming dates)\s*:?\s*$", re.I)
DATES_END = re.compile(r"^\s*(see you at the gate|trinity church of england school)\b", re.I)


def sway_id(arg: str) -> str:
    m = ID_RE.search(arg.strip())
    if not m:
        raise SystemExit(f"Not a Sway link or id: {arg}")
    return m.group(1)


def fetch(sid: str) -> dict:
    req = urllib.request.Request(
        ENDPOINT.format(id=sid),
        data=b"{}",
        method="POST",
        headers={"Content-Type": "application/json", "User-Agent": "school-newsletter-reader/1.0"},
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        raw = resp.read()
    if raw[:2] == b"\x1f\x8b":
        raw = gzip.decompress(raw)
    return json.loads(raw.decode("utf-8"))


def _runs(node) -> list[str]:
    """All text-run strings under a node, in order."""
    out: list[str] = []
    if isinstance(node, dict):
        if node.get("type") == "Node-TextRunElement":
            t = (node.get("props") or {}).get("Text")
            if isinstance(t, str):
                out.append(t)
        for v in node.values():
            if isinstance(v, (dict, list)):
                out.extend(_runs(v))
    elif isinstance(node, list):
        for x in node:
            out.extend(_runs(x))
    return out


def extract(data: dict) -> tuple[str, list[str]]:
    title = ""
    paragraphs: list[str] = []

    def walk(node):
        nonlocal title
        if isinstance(node, dict):
            props = node.get("props") or {}
            if node.get("type") == "Node-RenderModelRoot" and not title:
                title = props.get("Title", "")
            if node.get("type") == "Node-TextParagraph":
                text = "".join(_runs(node))
                text = re.sub(r"[ \t]*\r?\n[ \t]*", " ", text)  # Sway hard-wraps lines; unwrap
                text = re.sub(r"\s{2,}", " ", text).strip()
                if text:
                    paragraphs.append(text)
                return  # runs already collected; don't descend twice
            for v in node.values():
                if isinstance(v, (dict, list)):
                    walk(v)
        elif isinstance(node, list):
            for x in node:
                walk(x)

    walk(data)
    # Sway sometimes stores the same paragraph twice (layout variants); drop exact repeats in a row
    deduped = [p for i, p in enumerate(paragraphs) if i == 0 or p != paragraphs[i - 1]]
    return title, deduped


def important_dates(paragraphs: list[str]) -> list[str]:
    out, on = [], False
    for p in paragraphs:
        if DATES_START.match(p):
            on = True
            continue
        if on:
            if DATES_END.match(p):
                break
            if p.lower().startswith("upcoming dates"):
                continue
            out.append(p)
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("links", nargs="+", help="Sway URLs or ids")
    ap.add_argument("--dates", action="store_true", help="print only the Important Dates list")
    ap.add_argument("--save", metavar="DIR", help="also save full text to DIR/<title>.txt")
    args = ap.parse_args()

    for link in args.links:
        sid = sway_id(link)
        try:
            title, paras = extract(fetch(sid))
        except Exception as e:  # keep going for the other links
            print(f"### {sid}: FAILED: {e}", file=sys.stderr)
            continue
        print(f"### {title or sid}  (https://sway.cloud.microsoft/{sid})")
        if args.dates:
            dates = important_dates(paras)
            print("\n".join(dates) if dates else "(no Important Dates section found; read the full text)")
        else:
            print("\n\n".join(paras))
        print()
        if args.save:
            d = Path(args.save)
            d.mkdir(parents=True, exist_ok=True)
            safe = re.sub(r"[^\w\- ]+", "", title or sid).strip() or sid
            (d / f"{safe}.txt").write_text(
                f"{title}\nhttps://sway.cloud.microsoft/{sid}\n\n" + "\n\n".join(paras) + "\n", encoding="utf-8"
            )


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
