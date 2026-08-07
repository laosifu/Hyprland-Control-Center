#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

echo "== Normal =="

command_run echo hello

echo

echo "== Dry Run =="

execution_set_dry_run true

command_run echo hello
echo

echo "== Verbose =="

execution_set_dry_run false
execution_set_verbose true

command_run echo hello

echo

echo "== Verbose + Dry Run =="

execution_set_dry_run true

command_run echo hello