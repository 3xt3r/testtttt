#!/usr/bin/env python3
import argparse
import csv
import json
import re
from pathlib import Path


def canon(s: str) -> str:
    return re.sub(r"[-_.]+", "-", (s or "").strip().lower())


def display_name(c: dict) -> str:
    name = c.get("name", "") or ""
    group = c.get("group", "") or ""
    purl = c.get("purl", "") or ""
    if purl.startswith("pkg:maven/") and group:
        return f"{group}:{name}"
    return name


def version_eq(a: str, b: str) -> bool:
    if a == b:
        return True
    if a.startswith("v") and a[1:] == b:
        return True
    if b.startswith("v") and b[1:] == a:
        return True
    return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--results", type=Path, required=True)
    ap.add_argument("--expected", type=Path, required=True)
    args = ap.parse_args()

    with args.expected.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    bad = 0
    print("fixture,from,to,observed,status")
    for row in rows:
        bom_path = args.results / f'{row["fixture"]}.bom.json'
        if not bom_path.exists():
            print(f'{row["fixture"]},{row["from_name"]}@{row["from_version"]},{row["to_name"]}@{row["to_version"]},false,NO_BOM')
            bad += 1
            continue

        data = json.loads(bom_path.read_text(encoding="utf-8"))
        refs = {}
        for c in data.get("components", []):
            ref = c.get("bom-ref")
            if ref:
                refs[ref] = (canon(display_name(c)), str(c.get("version", "") or ""))

        edges = set()
        for d in data.get("dependencies", []) or []:
            src = d.get("ref")
            for dst in d.get("dependsOn", []) or []:
                if src in refs and dst in refs:
                    edges.add((src, dst))

        want_from_name = canon(row["from_name"])
        want_to_name = canon(row["to_name"])
        observed = False
        for src, dst in edges:
            sn, sv = refs[src]
            dn, dv = refs[dst]
            if sn == want_from_name and dn == want_to_name and version_eq(sv, row["from_version"]) and version_eq(dv, row["to_version"]):
                observed = True
                break

        status = "PASS" if observed else "FAIL"
        if not observed:
            bad += 1
        print(f'{row["fixture"]},{row["from_name"]}@{row["from_version"]},{row["to_name"]}@{row["to_version"]},{str(observed).lower()},{status}')

    raise SystemExit(1 if bad else 0)


if __name__ == "__main__":
    main()
