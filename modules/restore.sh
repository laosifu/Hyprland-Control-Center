#!/usr/bin/env bash

run_restore() {

    print_header "Restore Engine"

    local selected="${1:-}"
    local count=0

    if [[ -n "$selected" ]]; then
        local backup="$(get_backup_dir)/$selected"

        [[ -d "$backup" ]] || {
            print_error "Backup not found: $selected"
            return 1
        }

        read -rp "Restore $selected into $HOME? [y/N]: " answer
        case "$answer" in
            [Yy]|[Yy][Ee][Ss])
                backup_restore_snapshot "$backup"
                print_success "Restore completed"
                return 0
                ;;
            *)
                print_warning "Restore cancelled."
                return 0
                ;;
        esac
    fi

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
