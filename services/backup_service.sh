#!/usr/bin/env bash

backup_service_backup_directory() {

    local source="$1"
    local destination="$2"

    filesystem_service_exists \
        "$source" \
    || return 0

    filesystem_service_copy_directory \
        "$source" \
        "$destination"

}
