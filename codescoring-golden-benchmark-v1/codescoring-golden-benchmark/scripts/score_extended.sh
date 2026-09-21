#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rc=0
"$ROOT/scripts/score.sh" || rc=1
if [[ -f "$ROOT/results/hash-and-archives.bom.json" ]]; then
  python3 "$ROOT/scripts/check_optional_components.py" --bom "$ROOT/results/hash-and-archives.bom.json" --expected "$ROOT/expected/archive_components.csv" || rc=1
else
  echo "SKIP hash-and-archives: no result"
fi
if [[ -f "$ROOT/results/docker.bom.json" ]]; then
  python3 "$ROOT/scripts/check_optional_components.py" --bom "$ROOT/results/docker.bom.json" --expected "$ROOT/expected/docker_components.csv" || rc=1
else
  echo "SKIP docker: no result"
fi
exit "$rc"
