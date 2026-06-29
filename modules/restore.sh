#!/usr/bin/env bash

run_restore() {

    print_header "Restore Engine"

    local count=0

    echo

    print_info "Available backups"

    echo

    while read -r backup
    do

        [[ -z "$backup" ]] && continue

        ((++count))
            manifest_load "$backup"
        
        printf "%2d) %s\n\n" \
            "$count" \
            "$(basename "$backup")"

        printf "    %-10s %s\n" "Hyprland:" "$MANIFEST_HYPRLAND"
        printf "    %-10s %s\n" "OS:" "$MANIFEST_OS"
        printf "    %-10s %s\n" "Desktop:" "$MANIFEST_DESKTOP"
        printf "    %-10s %s\n" "Date:" "$MANIFEST_DATE"
        echo

        printf '%0.s-' {1..40}

        echo
        echo

    done < <(list_backups)

    echo

    print_info "Total backups: $count"

}