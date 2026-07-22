#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

execution_set_dry_run true

git_service_clone \
    https://github.com/mailong2401/cartoon-shell.git \
    ~/.config/quickshell/cartoon-shell