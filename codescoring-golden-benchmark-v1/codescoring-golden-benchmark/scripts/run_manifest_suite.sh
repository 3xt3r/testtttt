#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JOHNNY="${JOHNNY:-johnny}"
: "${JOHNNY_API_URL:?Set JOHNNY_API_URL}"
: "${JOHNNY_API_TOKEN:?Set JOHNNY_API_TOKEN}"
mkdir -p "$ROOT/results"

fixtures=(python-vulnerable python-fixed npm-vulnerable npm-fixed go-vulnerable go-fixed maven-vulnerable maven-fixed conan-cpp)

run_one() {
  local f="$1"
  echo "===== $f ====="
  "$JOHNNY" scan dir "$ROOT/cases/$f" \
    --api_url "$JOHNNY_API_URL" \
    --api_token "$JOHNNY_API_TOKEN" \
    --project "cs-benchmark-$f" \
    --create-project \
    --save-results \
    --stage source \
    --bom-path "$ROOT/results/$f.bom.json" \
    --bom-format cyclonedx_v1_6_json \
    --format "coloredtable,csv>>$ROOT/results/$f.vulns.csv"
  rc=$?
  if [[ $rc -ge 2 ]]; then
    echo "Johnny failed for $f with rc=$rc" >&2
    return "$rc"
  fi
  return 0
}

failed=0
for f in "${fixtures[@]}"; do
  run_one "$f" || failed=1
done
exit "$failed"
