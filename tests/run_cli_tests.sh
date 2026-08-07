#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"

trap 'rm -rf "$TEST_HOME"' EXIT

source "$PROJECT_ROOT/tests/lib/assert.sh"

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
    "Help command" \
    "$PROJECT_ROOT/bin/hcc" \
    --help

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
    env "HOME=$TEST_HOME" "$PROJECT_ROOT/bin/hcc" \
    backup

assert_success \
    "Restore list command" \
    env "HOME=$TEST_HOME" "$PROJECT_ROOT/bin/hcc" \
    restore

assert_success \
    "Theme list command" \
    "$PROJECT_ROOT/bin/hcc" \
    theme list

assert_success \
    "Plugin list command" \
    "$PROJECT_ROOT/bin/hcc" \
    plugins

assert_success \
    "Profile list command" \
    env "HOME=$TEST_HOME" "HCC_DATA_DIR=$TEST_HOME/state" "$PROJECT_ROOT/bin/hcc" \
    profile list

assert_success \
    "Repository inspect command" \
    "$PROJECT_ROOT/bin/hcc" \
    inspect "$PROJECT_ROOT/tests/fixtures/valid-profile"

print_summary
