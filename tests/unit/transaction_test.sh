#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

transaction_reset

transaction_register "echo rollback-1"

transaction_register "echo rollback-2"

transaction_register "echo rollback-3"

transaction_rollback
