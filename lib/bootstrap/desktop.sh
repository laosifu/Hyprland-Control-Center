#!/usr/bin/env bash

source "$PROJECT_ROOT/lib/plugins.sh"
source "$PROJECT_ROOT/lib/themes.sh"

source "$PROJECT_ROOT/lib/desktop_registry.sh"
source "$PROJECT_ROOT/lib/desktop_packages.sh"
source "$PROJECT_ROOT/lib/profile_registry.sh"
source "$PROJECT_ROOT/lib/repository_inspector.sh"
source "$PROJECT_ROOT/lib/desktop_manifest.sh"

source "$PROJECT_ROOT/lib/desktop_prepare_backup.sh"
source "$PROJECT_ROOT/lib/desktop_prepare.sh"
source "$PROJECT_ROOT/lib/desktop_finalize.sh"
source "$PROJECT_ROOT/lib/desktop_pipeline.sh"
source "$PROJECT_ROOT/lib/desktop_planner.sh"
