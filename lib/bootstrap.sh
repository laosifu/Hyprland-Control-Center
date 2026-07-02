#!/usr/bin/env bash
if [[ -z "${PROJECT_ROOT:-}" ]]; then

    PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fi

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
source "$PROJECT_ROOT/lib/execution_context.sh"
source "$PROJECT_ROOT/lib/privilege.sh"
source "$PROJECT_ROOT/lib/command_runner.sh"
source "$PROJECT_ROOT/lib/plan_executor.sh"
source "$PROJECT_ROOT/lib/action_dispatcher.sh"
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
#
# Actions
#
source "$PROJECT_ROOT/lib/action_types.sh"
source "$PROJECT_ROOT/lib/action_engine.sh"