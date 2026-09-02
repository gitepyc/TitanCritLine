#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

docker build -q -t titancritline-luacheck:5.1 \
  -f tests/lint/Dockerfile tests/lint >/dev/null

docker run --rm -v "$PWD":/addon:ro titancritline-luacheck:5.1 .
