#!/usr/bin/env bash

if [[ -n "${HCC_HANDLERS_BOOTSTRAP_LOADED:-}" ]]; then
    return
fi

readonly HCC_HANDLERS_BOOTSTRAP_LOADED=1

source "$PROJECT_ROOT/handlers/package_handler.sh"
source "$PROJECT_ROOT/handlers/aur_handler.sh"
source "$PROJECT_ROOT/handlers/git_handler.sh"
source "$PROJECT_ROOT/handlers/filesystem_handler.sh"