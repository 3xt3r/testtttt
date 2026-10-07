#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/cases/hash-and-archives"
mkdir -p "$OUT"

command -v curl >/dev/null || { echo "curl required" >&2; exit 2; }

# Maven JAR - archive scan + known vulnerable component
curl -fL --retry 3 \
  -o "$OUT/log4j-core-2.14.1.jar" \
  "https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.14.1/log4j-core-2.14.1.jar"

# Pure-Python wheel - archive/hash fixture. Let pip select the canonical published file.
command -v python3 >/dev/null || { echo "python3 required" >&2; exit 2; }
python3 -m pip download --no-deps --only-binary=:all: --dest "$OUT" "urllib3==1.26.4"

# npm published tarball + direct .min.js inclusion
if command -v npm >/dev/null; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  (cd "$tmp" && npm pack lodash@4.17.20 --silent >/dev/null)
  cp "$tmp/lodash-4.17.20.tgz" "$OUT/"
  tar -xzf "$tmp/lodash-4.17.20.tgz" -C "$tmp"
  if [[ -f "$tmp/package/lodash.min.js" ]]; then
    cp "$tmp/package/lodash.min.js" "$OUT/lodash-4.17.20.min.js"
  fi
else
  echo "npm not found: skipping lodash tgz/min.js" >&2
fi

echo "Prepared artifacts in $OUT"
