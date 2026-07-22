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

    desktop_finalize || return 1

    hook_service_run "$(desktop_package_hook "$ID" post-install)"

}
