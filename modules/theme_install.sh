#!/usr/bin/env bash

run_theme_install() {

    ui_header "Theme Installer"

    local name="$1"

    if [[ -z "$name" ]]; then

        print_error "Theme name required"

        return 1

    fi

    local theme

    theme="$(theme_directory "$name")"

    if ! theme_directory_exists "$name"; then

        print_error "Theme not found"

        return 1

    fi

    if ! theme_validate "$theme"; then

        print_error "Theme validation failed"

        return 1

    fi

    theme_load "$theme"

    ui_section "Theme"

    ui_field "Name" "$NAME"
    ui_field "Version" "$VERSION"
    ui_field "Author" "$AUTHOR"
    ui_field "Description" "$DESCRIPTION"

    echo

    print_info "Executing install.sh"

    echo

    bash "$(theme_install_script "$theme")"

    local rc=$?

    echo

    if (( rc == 0 )); then

        print_success "Theme installed"

    else

        print_error "Theme installation failed"

        return "$rc"

    fi

}