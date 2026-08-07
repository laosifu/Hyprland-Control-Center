#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

record="$(plan_record_create PACKAGE kitty)"

[[ "$(plan_record_type "$record")" == "PACKAGE" ]]

[[ "$(plan_record_arg1 "$record")" == "kitty" ]]

[[ "$(plan_record_arg2 "$record")" == "" ]]

echo "[PASS] plan_record"
