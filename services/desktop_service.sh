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

desktop_render_plan() {

    print_info "Generated Actions"

    echo

    plan_reset

    desktop_generate_plan

    plan_render

    echo
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

    desktop_render_plan
    echo

}