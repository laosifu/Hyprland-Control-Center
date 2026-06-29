#!/usr/bin/env bash

has_command() {
    command -v "$1" >/dev/null 2>&1
}
has_package() {

    pacman -Q "$1" >/dev/null 2>&1

}
has_service() {

    systemctl list-unit-files "$1" >/dev/null 2>&1

}
detect_os() {

    source /etc/os-release

    echo "$PRETTY_NAME"

}
detect_desktop() {

    echo "${XDG_CURRENT_DESKTOP:-Unknown}"

}
detect_session() {

    echo "${XDG_SESSION_TYPE:-Unknown}"

}
detect_shell() {

    basename "$SHELL"

}
detect_ram() {

    free -h | awk '/Mem:/ {print $2}'

}
detect_cpu() {

    lscpu | awk -F: '/Model name/ {print $2}' | sed 's/^ *//'

}
detect_gpu() {

    lspci | grep -E "VGA|3D"

}
detect_display_manager() {

    basename "$(readlink /etc/systemd/system/display-manager.service)" .service

}