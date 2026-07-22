#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

repository_inspect "$PROJECT_ROOT/tests/fixtures/valid-profile" >/dev/null

if repository_inspect "$PROJECT_ROOT/tests/fixtures" >/dev/null 2>&1; then
    echo "Invalid repository manifest was accepted." >&2
    exit 1
fi

echo "[PASS] repository inspector"
