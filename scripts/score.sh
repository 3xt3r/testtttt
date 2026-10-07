#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$ROOT/scripts/check_sboms.py" --results "$ROOT/results" --expected "$ROOT/expected/components.csv"; rc1=$?
python3 "$ROOT/scripts/check_dependencies.py" --results "$ROOT/results" --expected "$ROOT/expected/dependencies.csv"; rc2=$?
python3 "$ROOT/scripts/check_target_vulns.py" --results "$ROOT/results" --expected "$ROOT/expected/target_vulnerabilities.csv"; rc3=$?
[[ $rc1 -eq 0 && $rc2 -eq 0 && $rc3 -eq 0 ]]
