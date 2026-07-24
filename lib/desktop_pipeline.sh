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

    local id="${ID:-}"

    if [[ -n "$id" ]]; then

        session_register "$id" "${NAME:-}" "${VERSION:-}" "${SOURCE_URL:-local}"

        SESSION_INSTALL_ID="$id"

    fi

    deployment_service_execute_plan

    unset SESSION_INSTALL_ID

}

desktop_pipeline_finalize() {

    local id="${ID:-}"

    if [[ -n "$id" ]]; then

        session_build_manifest_from_plan "$id" 2>/dev/null || true

        session_deploy "$id"

        if [[ -w "/usr/share/wayland-sessions" ]]; then

            session_setup_login_entry "$id" 2>/dev/null || true

        else

            print_info "Login entry: select this desktop right at the login screen."
            local answer
            read -rp "Create login entry now (needs sudo password)? [y/N]: " answer
            case "$answer" in
                [Yy]*)
                    if [[ -n "${PROJECT_ROOT:-}" ]]; then
                        print_info "Creating login entry (sudo will ask for password)..."
                        sudo HOME="$HOME" bash -c \
                            "source '${PROJECT_ROOT}/lib/bootstrap.sh'; \
                             source '${PROJECT_ROOT}/lib/session.sh'; \
                             session_setup_login_entries" \
                        && print_success "Login entry created." \
                        || print_warning "Failed. Run later: sudo hcc session setup-login"
                    else
                        print_error "Cannot find HCC project root"
                    fi
                    ;;
                *)
                    print_info "Skip login entry. Create later: sudo hcc session setup-login"
                    ;;
            esac

        fi

    fi

    desktop_finalize_message

    hook_service_run "$(desktop_package_hook "$ID" post-install)"

}
