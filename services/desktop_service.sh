#!/usr/bin/env bash

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

    print_header "Desktop Package Planner"

    ui_field "Package" "$NAME"
    ui_field "Version" "$VERSION"
    ui_field "Author" "$AUTHOR"

    echo

    ui_field "Pacman Packages" \
        "$(desktop_plan_package_count)"

    ui_field "AUR Packages" \
        "$(desktop_plan_aur_count)"

    ui_field "Directories" \
        "$(desktop_plan_directory_count)"

    ui_field "Repositories" \
        "$(desktop_plan_repository_count)"

    ui_field "Reboot" \
        "$REBOOT_REQUIRED"

    echo

    print_info "Generated Actions"

    echo

    render_action "$(action_install_package hyprland)"
    render_action "$(action_install_package kitty)"
    render_action "$(action_install_aur quickshell-git)"
    render_action "$(action_copy_directory .config)"
    render_action "$(action_clone_repository \
        "https://github.com/mailong2401/cartoon-shell.git" \
        "~/.config/quickshell/cartoon-shell")"

}