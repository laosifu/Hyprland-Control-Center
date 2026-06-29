#!/usr/bin/env bash

write_manifest() {

    local target="$1"

    local file="$target/manifest.txt"
    
    if has_command Hyprland; then

        hypr_ver="$(Hyprland --version | head -n1)"

    else

        hypr_ver="Not installed"

    fi

    {

        echo "Hyprland Control Center"

        echo

        echo "Version=$VERSION"

        echo "Date=$(date)"

        echo "OS=$(detect_os)"

        echo "Desktop=$(detect_desktop)"

        echo "Session=$(detect_session)"

        echo "Hyprland=$hypr_ver"

    } > "$file"

}