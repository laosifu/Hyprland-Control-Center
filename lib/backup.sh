#!/usr/bin/env bash

list_backups() {

    local backup_root

    backup_root="$(get_backup_dir)"

    [[ -d "$backup_root" ]] || return

    find "$backup_root" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        | sort

}