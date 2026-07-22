#!/usr/bin/env bash

validate_plugin() {

    local plugin_dir="$1"

    if ! plugin_exists "$plugin_dir"; then

        print_error "Plugin metadata missing"

        return 1

    fi

    if ! plugin_validate "$plugin_dir"; then

        print_error "Plugin validation failed"

        return 1

    fi

    return 0

}
execute_plugin() {

    local plugin_dir="$1"

    local script="$plugin_dir/install.sh"

    if [[ ! -f "$script" ]]; then

        print_error "install.sh not found"

        return 1

    fi

    if [[ ! -x "$script" ]]; then

        chmod +x "$script"
    fi

    print_info "Executing install.sh"

    "$script"

}
run_plugin_install() {

    ui_header "Plugin Installer"

    local plugin="$1"

    if [[ -z "$plugin" ]]; then

        print_error "Plugin name required"

        return 1

    fi

    local plugin_dir

    plugin_dir="$PROJECT_ROOT/plugins/$plugin"

   if ! validate_plugin "$plugin_dir"; then

    return 1

    fi

    plugin_load "$plugin_dir"
    echo

    print_success "Plugin validation passed"
    echo

    ui_section "Requirements"

    show_dependencies "$plugin_dir"

    echo

    ui_field "Plugin" "$PLUGIN_NAME"

    ui_field "Version" "$PLUGIN_VERSION"

    ui_field "Author" "$PLUGIN_AUTHOR"

    echo

    print_success "Validation complete"

    echo

    execute_plugin "$plugin_dir"

    echo

    print_success "Plugin installed"
}

run_plugin_uninstall() {

    local plugin="$1"
    local plugin_dir
    local script

    [[ -n "$plugin" ]] || {
        print_error "Plugin name required"
        return 1
    }

    plugin_dir="$PROJECT_ROOT/plugins/$plugin"
    validate_plugin "$plugin_dir" || return 1

    script="$plugin_dir/uninstall.sh"
    print_info "Executing uninstall.sh"
    command_run bash "$script"

}
