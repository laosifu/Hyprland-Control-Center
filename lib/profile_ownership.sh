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

profile_ownership_restore() {
    local id="$1"
    local plan_file
    local dirs_restored=0

    profile_registry_load "$id" || return 1

    plan_file="$(profile_registry_directory "$id")/ownership.plan"
    [[ -f "$plan_file" ]] || {
        print_info "No ownership plan found for profile: $id"
        return 0
    }

    if [[ -z "${PROFILE_PREVIOUS_SNAPSHOT:-}" || ! -d "$PROFILE_PREVIOUS_SNAPSHOT" ]]; then
        print_warning "No snapshot found for profile: $id"
        print_info "Files must be restored manually."
        return 1
    fi

    local snapshot="$PROFILE_PREVIOUS_SNAPSHOT"

    print_info "Restoring from snapshot: $snapshot"
    echo

    while IFS='|' read -r ptype parg1 parg2
    do
        [[ -z "$ptype" ]] && continue

        case "$ptype" in
            COPY_DIRECTORY)
                local dir_name
                dir_name="$(basename "$parg1")"
                local snapshot_dir="$snapshot/$dir_name"

                if [[ -d "$snapshot_dir" ]]; then
                    filesystem_service_copy_directory "$snapshot_dir" "$parg2"
                    print_success "Restored: $dir_name → $parg2"
                    ((dirs_restored++))
                else
                    print_warning "Snapshot directory not found: $dir_name"
                fi
                ;;
        esac
    done < "$plan_file"

    echo
    print_info "Restored $dirs_restored directories."
}
