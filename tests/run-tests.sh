#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

source "$PROJECT_ROOT/tests/assert.sh"

echo
echo "========================================"
echo "HCC Test Framework"
echo "========================================"
echo

assert_success \
    "Version command" \
    "$PROJECT_ROOT/bin/hcc" \
    --version

assert_success \
    "Doctor command" \
    "$PROJECT_ROOT/bin/hcc" \
    doctor

assert_success \
    "Cleanup command" \
    "$PROJECT_ROOT/bin/hcc" \
    cleanup

assert_success \
    "Backup command" \
    "$PROJECT_ROOT/bin/hcc" \
    backup

print_summary
