#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "== Running Unit Tests =="

for test in "$PROJECT_ROOT"/tests/unit/*_test.sh
do
    echo
    echo ">>> $(basename "$test")"
    bash "$test"
done

echo
echo "All tests passed."
echo
