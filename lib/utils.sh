#!/usr/bin/env bash
scan_directory() {

    local dir="$1"

    [[ -d "$dir" ]] || return 1

    du -sh "$dir" 2>/dev/null | cut -f1

}
scan_and_print() {

    local label="$1"
    local dir="$2"

    local size

    if size=$(scan_directory "$dir"); then

        print_info "$label : $size"

    else

        print_warning "$label : Not found"

    fi

}
show_help() {

cat <<EOF

Hyprland Control Center

Usage:

    hcc doctor

    hcc cleanup

    hcc restore

    hcc --version

EOF

}