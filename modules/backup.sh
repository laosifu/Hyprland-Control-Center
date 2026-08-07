#!/usr/bin/env bash

create_backup() {

    local target

    target="$(backup_create_snapshot)" || return 1

    print_info "Backup directory: $target"

    print_success "Backup completed"

}

run_backup() {

    print_header "Backup Engine"

    create_backup

}

run_backup_list() {

    local backup
    local count=0

    print_header "Backup Engine"

    echo

    print_info "Available backups"

    echo

    while read -r backup
    do

        [[ -z "$backup" ]] && continue

        ((++count))

        printf "%2d) %s\n\n" \
            "$count" \
            "$(basename "$backup")"

        printf "    %-10s %s\n" "Date:" "$(basename "$backup" | sed -E 's/^([0-9]{8})-([0-9]{6}).*/\1 \2/')"

        echo

    done < <(list_backups)

    echo

    print_info "Total backups: $count"
    print_info "Restore: hcc backup restore <name>"

}
