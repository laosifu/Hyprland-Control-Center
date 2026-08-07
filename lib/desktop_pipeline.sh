#!/usr/bin/env bash

desktop_pipeline_run() {

    desktop_pipeline_prepare \
    || return 1

    desktop_pipeline_execute \
    || return 1

    desktop_pipeline_finalize

}
desktop_pipeline_prepare() {

    desktop_prepare

}

desktop_pipeline_execute() {

    deployment_service_execute_plan

}

desktop_pipeline_finalize() {

    local id="${ID:-}"

    if [[ -n "$id" ]]; then
        dm_install_entry "HCC" "/usr/lib/hcc/session-launcher" 2>/dev/null || true
    fi

    desktop_finalize_message

    hook_service_run "$(desktop_package_hook "$ID" post-install)"

}
