#!/usr/bin/env bash

desktop_render_summary() {

    print_header "Desktop Package Planner"

    ui_field "Package" "$NAME"
    ui_field "Version" "$VERSION"
    ui_field "Author" "$AUTHOR"

    echo

    ui_field "Reboot" "$REBOOT_REQUIRED"

    echo
}

desktop_generate_install_plan() {

    plan_reset

    desktop_generate_plan

}

desktop_render_plan() {

    print_info "Generated Actions"

    echo

    plan_render

    echo
}

desktop_confirm_execution() {

    echo

    read -rp "Continue installation? [y/N]: " answer

    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            print_warning "Installation cancelled."
            return 1
            ;;
    esac

}

desktop_execute_plan() {

    require_root desktop install "$NAME" || return 1

    print_info "Executing plan"

    echo

    plan_execute

}

desktop_service_install() {

    local desktop="$1"

    if [[ -z "$desktop" ]]; then

        print_error "Desktop package required"

        return 1

    fi

    if ! desktop_package_load "$desktop"; then

        print_error "Desktop package not found"

        return 1

    fi

    desktop_render_summary

    desktop_generate_install_plan

    desktop_render_plan

    if ! desktop_confirm_execution; then
        return 0
    fi

    desktop_execute_plan

    echo

}