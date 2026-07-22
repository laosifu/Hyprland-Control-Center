#!/usr/bin/env bash

backup_create() {

    local source="$1"
    local destination="$2"

    backup_service_create_directory \
        "$destination"

    backup_service_copy \
        "$source" \
        "$destination"

}

backup_create_snapshot() {

    local backup_root
    local target
    local source
    local source_path
    local destination

    backup_root="$(get_backup_dir)"
    target="$backup_root/$(date +%Y%m%d-%H%M%S-%N)"

    filesystem_service_create_directory "$target" || return 1
    write_manifest "$target" || return 1

    while read -r source
    do
        [[ -z "$source" ]] && continue

        source_path="${source/#\~/$HOME}"
        destination="$target/$(basename "$source_path")"

        backup_service_backup_directory "$source" "$destination" || return 1
    done < <(backup_target_list)

    echo "$target"

}

backup_restore() {

    local backup="$1"
    local destination="$2"

    backup_service_copy \
        "$backup" \
        "$destination"

}

backup_restore_snapshot() {

    local backup="$1"
    local backup_root
    local source

    backup_root="$(get_backup_dir)"

    case "$backup" in
        "$backup_root"/*)
            ;;
        *)
            print_error "Backup must be located in $backup_root"
            return 1
            ;;
    esac

    [[ -d "$backup" ]] || {
        print_error "Backup not found: $backup"
        return 1
    }

    for source in "$backup"/*
    do
        [[ -d "$source" ]] || continue

        filesystem_service_copy_directory "$source" "$HOME" || return 1
    done

}

list_backups() {

    local backup_root

    backup_root="$(get_backup_dir)"

    [[ -d "$backup_root" ]] || return 0

    find "$backup_root" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        | sort

}
