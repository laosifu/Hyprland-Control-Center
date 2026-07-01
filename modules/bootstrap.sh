#!/usr/bin/env bash

source "$PROJECT_ROOT/modules/doctor.sh"
source "$PROJECT_ROOT/modules/cleanup.sh"

source "$PROJECT_ROOT/modules/backup.sh"
source "$PROJECT_ROOT/modules/restore.sh"

source "$PROJECT_ROOT/modules/inventory.sh"

source "$PROJECT_ROOT/modules/plugins.sh"
source "$PROJECT_ROOT/modules/plugin_install.sh"

source "$PROJECT_ROOT/modules/themes.sh"
source "$PROJECT_ROOT/modules/theme_install.sh"

source "$PROJECT_ROOT/modules/desktop_install.sh"