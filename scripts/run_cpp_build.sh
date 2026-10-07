#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JOHNNY="${JOHNNY:-johnny}"
: "${JOHNNY_API_URL:?Set JOHNNY_API_URL}"
: "${JOHNNY_API_TOKEN:?Set JOHNNY_API_TOKEN}"
command -v cmake >/dev/null || { echo "cmake required" >&2; exit 2; }
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "scan build ebpf requires root. Run: sudo -E ./scripts/run_cpp_build.sh" >&2
  exit 2
fi
mkdir -p "$ROOT/results" "$ROOT/cases/cpp-build/build"

cd "$ROOT/cases/cpp-build/build"
"$JOHNNY" scan build ebpf ../buildConfig.json \
  --api_url "$JOHNNY_API_URL" \
  --api_token "$JOHNNY_API_TOKEN" \
  --project "cs-benchmark-cpp-build" \
  --create-project --save-results --stage build \
  --bom-path "$ROOT/results/cpp-build.bom.json"
rc=$?
[[ $rc -lt 2 ]]
