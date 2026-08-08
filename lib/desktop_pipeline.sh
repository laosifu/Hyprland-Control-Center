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
        desktop_pipeline_setup_login
    fi

    desktop_finalize_message

    hook_service_run "$(desktop_package_hook "$ID" post-install)"

}

desktop_pipeline_setup_login() {

    local name
    local default_name="${SESSION_NAME:-HCC}"

    if [[ -t 0 && "${AUTO_CONFIRM:-false}" != "true" ]]; then
        read -rp "Dat ten session dang nhap (Enter de dung '${default_name}'): " name
    else
        name=""
    fi
    name="${name:-$default_name}"

    if [[ "$name" != "$default_name" ]]; then
        print_info "Luu ten session '${name}' vao cau hinh..."
        config_set_value "SESSION_NAME" "$name"
    fi

    dm_install_entry "$name" "/usr/lib/hcc/session-launcher"
    print_success "Da tao login entry: $name"
    echo "Logout → chon '$name' tren man hinh login"

}
