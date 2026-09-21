#!/usr/bin/env python3
import argparse
import csv
import json
import re
from collections import defaultdict
from pathlib import Path
from urllib.parse import unquote


def canon_name(s: str) -> str:
    return re.sub(r"[-_.]+", "-", (s or "").strip().lower())


def load_expected(path: Path):
    by_fixture = defaultdict(list)
    with path.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            by_fixture[row["fixture"]].append(row)
    return by_fixture


def purl_type(purl: str) -> str:
    if not purl.startswith("pkg:"):
        return ""
    return purl[4:].split("/", 1)[0]


def component_key(c: dict):
    name = c.get("name", "")
    group = c.get("group", "") or ""
    version = str(c.get("version", "") or "")
    purl = c.get("purl", "") or ""
    typ = purl_type(purl)
    if typ == "maven" and group:
        name = f"{group}:{name}"
    return canon_name(name), version, purl


def version_equiv(expected: str, actual: str) -> bool:
    if expected == actual:
        return True
    # Go module versions are often rendered with or without a leading v.
    if expected.startswith("v") and expected[1:] == actual:
        return True
    if actual.startswith("v") and actual[1:] == expected:
        return True
    return False


def purl_equiv(expected: str, actual: str) -> bool:
    if not expected or not actual:
        return True
    # Ignore optional qualifiers/subpath; compare the canonical package identity.
    e = unquote(expected).split("?", 1)[0].split("#", 1)[0].lower()
    a = unquote(actual).split("?", 1)[0].split("#", 1)[0].lower()
    return e == a


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--results", type=Path, required=True)
    ap.add_argument("--expected", type=Path, required=True)
    args = ap.parse_args()

    expected = load_expected(args.expected)
    total_expected = found = exact_versions = purl_ok = 0
    failures = 0

    print("fixture,expected,found,version_exact,purl_ok,missing")
    for fixture, rows in sorted(expected.items()):
        bom = args.results / f"{fixture}.bom.json"
        if not bom.exists():
            print(f"{fixture},{len(rows)},0,0,0,NO_BOM")
            failures += len(rows)
            total_expected += len(rows)
            continue

        data = json.loads(bom.read_text(encoding="utf-8"))
        components = data.get("components", [])
        actual = [component_key(c) for c in components]
        fixture_found = fixture_exact = fixture_purl = 0
        missing = []

        for r in rows:
            total_expected += 1
            want_name = canon_name(r["name"])
            want_ver = r["version"]
            candidates = [x for x in actual if x[0] == want_name]
            if not candidates:
                missing.append(f'{r["name"]}@{want_ver}')
                failures += 1
                continue
            fixture_found += 1
            found += 1
            exact = [x for x in candidates if version_equiv(want_ver, x[1])]
            if exact:
                fixture_exact += 1
                exact_versions += 1
                if any(purl_equiv(r.get("purl", ""), x[2]) for x in exact):
                    fixture_purl += 1
                    purl_ok += 1
            else:
                missing.append(f'{r["name"]}@{want_ver}(wrong-version)')
                failures += 1

        print(
            f"{fixture},{len(rows)},{fixture_found},{fixture_exact},{fixture_purl},"
            + (';'.join(missing) if missing else '-')
        )

    def pct(a, b):
        return 100.0 * a / b if b else 0.0

    print("\nSUMMARY")
    print(f"expected_components={total_expected}")
    print(f"component_recall={pct(found,total_expected):.2f}% ({found}/{total_expected})")
    print(f"exact_version_accuracy={pct(exact_versions,total_expected):.2f}% ({exact_versions}/{total_expected})")
    print(f"purl_match_on_expected={pct(purl_ok,total_expected):.2f}% ({purl_ok}/{total_expected})")
    raise SystemExit(1 if failures else 0)


if __name__ == "__main__":
    main()
