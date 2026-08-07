#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

#test_header "Planner"

execution_set_dry_run true

transaction_reset

filesystem_service_create_directory ~/demo

transaction_rollback
