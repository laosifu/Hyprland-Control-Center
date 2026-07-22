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
