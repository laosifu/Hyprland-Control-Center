#!/usr/bin/env bash

if [[ -n "${HCC_MODULES_BOOTSTRAP_LOADED:-}" ]]; then
    return
fi

readonly HCC_MODULES_BOOTSTRAP_LOADED=1

source "$PROJECT_ROOT/modules/doctor.sh"
source "$PROJECT_ROOT/modules/cleanup.sh"

source "$PROJECT_ROOT/modules/backup.sh"
source "$PROJECT_ROOT/modules/restore.sh"

source "$PROJECT_ROOT/modules/inventory.sh"

source "$PROJECT_ROOT/modules/plugins.sh"
source "$PROJECT_ROOT/modules/plugin_install.sh"

source "$PROJECT_ROOT/modules/themes.sh"
source "$PROJECT_ROOT/modules/theme_install.sh"

source "$PROJECT_ROOT/modules/desktop_list.sh"
source "$PROJECT_ROOT/modules/desktop_install.sh"
source "$PROJECT_ROOT/modules/desktop_uninstall.sh"
source "$PROJECT_ROOT/modules/desktop_update.sh"
source "$PROJECT_ROOT/modules/desktop_init.sh"
source "$PROJECT_ROOT/modules/profiles.sh"
source "$PROJECT_ROOT/modules/inspect.sh"