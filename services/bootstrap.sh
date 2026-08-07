#!/usr/bin/env bash

if [[ -n "${HCC_SERVICES_BOOTSTRAP_LOADED:-}" ]]; then
    return
fi

readonly HCC_SERVICES_BOOTSTRAP_LOADED=1

source "$PROJECT_ROOT/operations/bootstrap.sh"

#
# Operations
#

source "$PROJECT_ROOT/operations/filesystem_operation.sh"
source "$PROJECT_ROOT/operations/package_operation.sh"
source "$PROJECT_ROOT/operations/git_operation.sh"
source "$PROJECT_ROOT/operations/aur_operation.sh"

#
# Services
#

source "$PROJECT_ROOT/services/filesystem_service.sh"
source "$PROJECT_ROOT/services/package_service.sh"
source "$PROJECT_ROOT/services/git_service.sh"
source "$PROJECT_ROOT/services/aur_service.sh"
source "$PROJECT_ROOT/services/backup_service.sh"
source "$PROJECT_ROOT/services/action_service.sh"
source "$PROJECT_ROOT/services/deployment_service.sh"
source "$PROJECT_ROOT/services/desktop_service.sh"
source "$PROJECT_ROOT/services/hook_service.sh"
