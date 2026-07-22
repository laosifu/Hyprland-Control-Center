#!/usr/bin/env bash

planner_copy() {

    local item
    local source
    local target

    while read -r item
    do

        [[ -z "$item" ]] && continue

        IFS='|' read -r source target <<< "$item"

        plan_copy_directory \
        "$PROJECT_ROOT/$PACKAGE_ROOT/$source" \
        "$target"

    done <<< "$COPY_ITEMS"

}
