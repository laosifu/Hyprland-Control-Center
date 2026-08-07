#!/usr/bin/env bash

run_doctor() {

    print_header "Hyprland Control Center"

    doctor_system_info

    echo

    doctor_health_check

    doctor_recommendations

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

doctor_recommendations() {
    local has_recommendations=false

    echo
    print_header "Goi y"

    if ! has_command Hyprland; then
        echo "  • Hyprland chua duoc cai dat"
        echo "    Giai phap: hcc desktop install <ten> (tu dong cai Hyprland)"
        has_recommendations=true
    fi

    if ! has_command yay && ! has_command paru && ! has_command trizen && ! has_command pamac; then
        echo "  • Khong tim thay AUR helper"
        echo "    Giai phap: cai yay (sudo pacman -S yay) hoac paru"
        has_recommendations=true
    fi

    local dm
    dm="$(detect_display_manager)"
    if [[ -z "$dm" || "$dm" == "none" ]]; then
        echo "  • Khong phat hien Display Manager"
        echo "    Giai phap: cai SDDM (sudo pacman -S sddm) va kich hoat (sudo systemctl enable sddm)"
        has_recommendations=true
    fi

    if [[ ! -f "/usr/share/wayland-sessions/hcc.desktop" ]]; then
        echo "  • Chua cau hinh login entry cho HCC"
        echo "    Giai phap: sudo hcc session setup-login"
        has_recommendations=true
    fi

    if ! command -v python3 &>/dev/null; then
        echo "  • Thieu python3 (TOML parser se dung pure-bash, cham hon)"
        echo "    Giai phap: sudo pacman -S python"
        has_recommendations=true
    fi

    if ! $has_recommendations; then
        echo "  Khong co goi y nao. He thong on dinh!"
    fi
}