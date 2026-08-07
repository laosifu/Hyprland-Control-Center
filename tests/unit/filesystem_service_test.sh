#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

execution_set_dry_run true

SOURCE="$(mktemp -d)"
DESTINATION="$(mktemp -d)"

filesystem_service_copy_directory \
    "$SOURCE" \
    "$DESTINATION"

rm -rf "$SOURCE"
rm -rf "$DESTINATION"