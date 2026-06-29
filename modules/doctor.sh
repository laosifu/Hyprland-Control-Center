#!/usr/bin/env bash

run_doctor() {

    print_header "Hyprland Control Center"

    doctor_system_info

    echo

    doctor_health_check

}

doctor_system_info() {

    print_info "OS: $(detect_os)"
    print_info "Desktop: $(detect_desktop)"
    print_info "Session: $(detect_session)"
    print_info "Shell: $(detect_shell)"
    print_info "RAM: $(detect_ram)"
    print_info "CPU: $(detect_cpu)"
    print_info "GPU: $(detect_gpu)"
    print_info "Display Manager: $(detect_display_manager)"

}

doctor_health_check() {

    doctor_check "Hyprland installed" \
        "$(has_command Hyprland && echo true || echo false)"

    doctor_check "Quickshell installed" \
        "$(has_command quickshell && echo true || echo false)"

    doctor_check "Wayland session" \
        "$( [[ "$(detect_session)" == "wayland" ]] && echo true || echo false )"

    doctor_check "Using SDDM" \
        "$( [[ "$(detect_display_manager)" == "sddm" ]] && echo true || echo false )"

}

doctor_check() {

    local title="$1"
    local result="$2"

    if [[ "$result" == "true" ]]; then
        print_success "[cac ha] $title"
    else
        print_error "[cac ha] $title"
    fi

}