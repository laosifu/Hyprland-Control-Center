#!/usr/bin/env bash

profile_ownership_record_plan() {

    local id="$1"
    local action
    local directory

    directory="$(profile_registry_directory "$id")"
    profile_registry_exists "$id" || return 1

    : > "$directory/ownership.plan"

    for action in "${PLAN_ACTIONS[@]}"
    do
        plan_record_read "$action"

        case "$PLAN_RECORD_TYPE" in
            COPY_DIRECTORY|CLONE_REPOSITORY)
                printf '%s|%s|%s\n' \
                    "$PLAN_RECORD_TYPE" "$PLAN_RECORD_ARG1" "$PLAN_RECORD_ARG2" \
                    >> "$directory/ownership.plan"
                ;;
        esac
    done

}
