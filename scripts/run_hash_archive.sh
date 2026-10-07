#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JOHNNY="${JOHNNY:-johnny}"
: "${JOHNNY_API_URL:?Set JOHNNY_API_URL}"
: "${JOHNNY_API_TOKEN:?Set JOHNNY_API_TOKEN}"
mkdir -p "$ROOT/results"

"$JOHNNY" scan dir "$ROOT/cases/hash-and-archives" \
  --api_url "$JOHNNY_API_URL" \
  --api_token "$JOHNNY_API_TOKEN" \
  --project "cs-benchmark-hash-archives" \
  --create-project --save-results --stage source \
  --with-hashes \
  --bom-path "$ROOT/results/hash-and-archives.bom.json" \
  --format "coloredtable,csv>>$ROOT/results/hash-and-archives.vulns.csv"
rc=$?
[[ $rc -lt 2 ]]
