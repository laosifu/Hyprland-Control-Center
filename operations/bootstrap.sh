#!/usr/bin/env bash

if [[ -n "${HCC_OPERATIONS_BOOTSTRAP_LOADED:-}" ]]; then
    return
fi

readonly HCC_OPERATIONS_BOOTSTRAP_LOADED=1

source "$PROJECT_ROOT/operations/filesystem_operation.sh"
source "$PROJECT_ROOT/operations/git_operation.sh"
source "$PROJECT_ROOT/operations/package_operation.sh"
source "$PROJECT_ROOT/operations/aur_operation.sh"
