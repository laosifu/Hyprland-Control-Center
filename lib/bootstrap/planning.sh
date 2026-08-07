#!/usr/bin/env bash

#
# Planners
#

source "$PROJECT_ROOT/lib/planners/package_planner.sh"
source "$PROJECT_ROOT/lib/planners/flatpak_planner.sh"
source "$PROJECT_ROOT/lib/planners/aur_planner.sh"
source "$PROJECT_ROOT/lib/planners/git_planner.sh"
source "$PROJECT_ROOT/lib/planners/copy_planner.sh"

#
# Plan
#

source "$PROJECT_ROOT/lib/action_types.sh"
source "$PROJECT_ROOT/lib/actions.sh"
source "$PROJECT_ROOT/lib/plan_record.sh"
source "$PROJECT_ROOT/lib/plan.sh"
source "$PROJECT_ROOT/lib/plan_builder.sh"
source "$PROJECT_ROOT/lib/plan_validator.sh"

#
# Execution
#

source "$PROJECT_ROOT/lib/action_dispatcher.sh"
source "$PROJECT_ROOT/lib/action_engine.sh"
source "$PROJECT_ROOT/lib/plan_executor.sh"
source "$PROJECT_ROOT/lib/plan_conflict.sh"
source "$PROJECT_ROOT/lib/plan_diff.sh"
