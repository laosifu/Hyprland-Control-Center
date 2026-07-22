#!/usr/bin/env bash

desktop_prepare() {

    if execution_is_dry_run; then
        DESKTOP_PREVIOUS_SNAPSHOT=""
        print_info "[DRY-RUN] A pre-install snapshot would be created."
    else
        DESKTOP_PREVIOUS_SNAPSHOT="$(backup_create_snapshot)" \
        || return 1

        print_info "Pre-install snapshot: $DESKTOP_PREVIOUS_SNAPSHOT"
    fi

    desktop_prepare_requirements \
    || return 1

    desktop_prepare_environment \
    || return 1

}

desktop_prepare_requirements() {

    if ! desktop_package_is_supported; then
        print_error "Desktop package does not support this distribution."
        return 1
    fi

    hook_service_run "$(desktop_package_hook "$ID" pre-install)"

}

desktop_prepare_environment() {

    return 0

}
