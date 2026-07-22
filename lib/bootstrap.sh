#!/usr/bin/env bash

if [[ -z "${PROJECT_ROOT:-}" ]]; then
    PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

if [[ -n "${HCC_LIB_BOOTSTRAP_LOADED:-}" ]]; then
    return
fi

readonly HCC_LIB_BOOTSTRAP_LOADED=1

#
# Bootstrap Modules
#

source "$PROJECT_ROOT/lib/bootstrap/core.sh"
source "$PROJECT_ROOT/lib/bootstrap/common.sh"
source "$PROJECT_ROOT/lib/bootstrap/runtime.sh"
source "$PROJECT_ROOT/lib/bootstrap/manifest.sh"
source "$PROJECT_ROOT/lib/bootstrap/planning.sh"
source "$PROJECT_ROOT/lib/bootstrap/desktop.sh"
source "$PROJECT_ROOT/lib/bootstrap/backup.sh"
source "$PROJECT_ROOT/lib/bootstrap/renderers.sh"
source "$PROJECT_ROOT/lib/bootstrap/commands.sh"
source "$PROJECT_ROOT/lib/bootstrap/queries.sh"