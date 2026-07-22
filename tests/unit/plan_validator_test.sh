#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

plan_reset

plan_add \
    "$(action_install_package kitty)"

plan_validate

echo "[PASS] valid plan"