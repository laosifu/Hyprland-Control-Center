#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_DATA="$(mktemp -d)"

trap 'rm -rf "$TEST_DATA"' EXIT

HCC_DATA_DIR="$TEST_DATA"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

profile_registry_register test-profile "Test Profile" "1.0.0" "https://example.invalid/profile" "/tmp/snapshot"
profile_registry_activate test-profile

[[ "$(profile_registry_active)" == test-profile ]]

profile_registry_load test-profile
[[ "$PROFILE_NAME" == "Test Profile" ]]
[[ "$PROFILE_PREVIOUS_SNAPSHOT" == /tmp/snapshot ]]

echo "[PASS] profile registry"
