#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JOHNNY="${JOHNNY:-johnny}"
: "${JOHNNY_API_URL:?Set JOHNNY_API_URL}"
: "${JOHNNY_API_TOKEN:?Set JOHNNY_API_TOKEN}"
command -v docker >/dev/null || { echo "docker required" >&2; exit 2; }
mkdir -p "$ROOT/results"

docker build -t codescoring-benchmark:v1 "$ROOT/cases/docker"

"$JOHNNY" scan image docker:codescoring-benchmark:v1 \
  --api_url "$JOHNNY_API_URL" \
  --api_token "$JOHNNY_API_TOKEN" \
  --project "cs-benchmark-docker" \
  --create-project --save-results --stage build \
  --pkg-types os-pkgs,lang-pkgs \
  --bom-path "$ROOT/results/docker.bom.json" \
  --format "coloredtable,csv>>$ROOT/results/docker.vulns.csv"
rc=$?
[[ $rc -lt 2 ]]
