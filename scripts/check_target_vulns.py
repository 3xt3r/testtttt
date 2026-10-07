#!/usr/bin/env python3
"""Best-effort checker for Johnny CSV reports.

Because CSV headings can change across Johnny/platform versions, this script searches each
fixture report text for both the target CVE and component name/version. It is intentionally
simple and transparent. If your Johnny CSV layout differs, inspect results/*.vulns.csv and
adapt the matching function.
"""
import argparse
import csv
from pathlib import Path


def norm(s: str) -> str:
    return (s or "").lower().replace("_", "-")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--results", type=Path, required=True)
    ap.add_argument("--expected", type=Path, required=True)
    args = ap.parse_args()
    bad = 0
    with args.expected.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    print("fixture,component,cve,expected,observed,status")
    for r in rows:
        report = args.results / f'{r["fixture"]}.vulns.csv'
        text = report.read_text(encoding="utf-8", errors="replace") if report.exists() else ""
        hay = norm(text)
        cve = norm(r["vulnerability"])
        name = norm(r["name"])
        version = norm(r["version"])
        # CVE must be present; component/version co-occurrence is checked loosely because
        # Johnny may group findings by vulnerability in CSV output.
        observed = cve in hay and name in hay and version in hay
        expected = r["expected_present"].strip().lower() == "true"
        ok = observed == expected
        if not ok:
            bad += 1
        print(f'{r["fixture"]},{r["name"]}@{r["version"]},{r["vulnerability"]},{expected},{observed},{"PASS" if ok else "FAIL"}')
    raise SystemExit(1 if bad else 0)


if __name__ == "__main__":
    main()
