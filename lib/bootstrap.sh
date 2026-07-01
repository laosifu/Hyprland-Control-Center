#!/usr/bin/env bash

#
# Core
#

source "$PROJECT_ROOT/lib/constants.sh"
source "$PROJECT_ROOT/lib/colors.sh"
source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/output.sh"
source "$PROJECT_ROOT/lib/ui.sh"

#
# Utilities
#

source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/config.sh"
source "$PROJECT_ROOT/lib/detect.sh"
source "$PROJECT_ROOT/lib/checks.sh"
source "$PROJECT_ROOT/lib/dependencies.sh"
source "$PROJECT_ROOT/lib/filesystem.sh"

#
# Manifest
#

source "$PROJECT_ROOT/lib/manifest.sh"
source "$PROJECT_ROOT/lib/manifest_reader.sh"
source "$PROJECT_ROOT/lib/requirements.sh"

#
# Plugin / Theme / Desktop
#

source "$PROJECT_ROOT/lib/plugins.sh"
source "$PROJECT_ROOT/lib/themes.sh"
source "$PROJECT_ROOT/lib/desktop_packages.sh"

#
# Planner
#

source "$PROJECT_ROOT/lib/actions.sh"
source "$PROJECT_ROOT/lib/plan.sh"
source "$PROJECT_ROOT/lib/desktop_planner.sh"

#
# Backup
#

source "$PROJECT_ROOT/lib/backup.sh"

#
# Renderers
#

source "$PROJECT_ROOT/lib/renderers/plugin_renderer.sh"
source "$PROJECT_ROOT/lib/renderers/theme_renderer.sh"
source "$PROJECT_ROOT/lib/renderers/action_renderer.sh"