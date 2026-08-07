#!/usr/bin/env bash
inventory_os() {

    detect_os

}

inventory_desktop() {

    detect_desktop

}

inventory_session() {

    detect_session

}

inventory_shell() {

    detect_shell

}

inventory_display_manager() {

    detect_display_manager

}
inventory_component() {

    local title="$1"

    local command="$2"

    if has_command "$command"; then

        print_success "✓ $title"

    else

        print_error "✗ $title"

    fi

}
inventory_command() {

    local title="$1"
    local command="$2"

    if check_command "$command"; then

        print_success "✓ $title"

    else

        print_error "✗ $title"

    fi

}
inventory_package() {

    local title="$1"
    local package="$2"

    if check_package "$package"; then

        print_success "✓ $title"

    else

        print_error "✗ $title"

    fi

}
inventory_service() {

    local title="$1"
    local service="$2"

    if check_service "$service"; then

        print_success "✓ $title"

    else

        print_error "✗ $title"

    fi

}
run_inventory() {

    print_header "Theme Inventory"

    echo

    print_info "Current Environment"

    echo

    printf "%-18s %s\n" "OS" "$(inventory_os)"

    printf "%-18s %s\n" "Desktop" "$(inventory_desktop)"

    printf "%-18s %s\n" "Session" "$(inventory_session)"

    printf "%-18s %s\n" "Shell" "$(inventory_shell)"

    printf "%-18s %s\n" "Display Manager" "$(inventory_display_manager)"
    
    echo

    print_info "Installed Components"

    echo

    inventory_command "Hyprland" "Hyprland"

    inventory_package "Quickshell" "quickshell"

    inventory_command "Waybar" "waybar"

    inventory_command "Kitty" "kitty"

    inventory_command "Fish" "fish"

    inventory_command "Git" "git"

    inventory_service "SDDM" "sddm.service"
}