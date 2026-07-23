#!/usr/bin/env bash

planner_copy() {

    local item
    local source
    local target

    local base="${PACKAGE_ROOT_DIR:-$PROJECT_ROOT}"

    while read -r item
    do

        [[ -z "$item" ]] && continue

        IFS='|' read -r source target <<< "$item"

        plan_copy_directory \
        "$base/$PACKAGE_ROOT/$source" \
        "$target"

    done <<< "$COPY_ITEMS"

}
