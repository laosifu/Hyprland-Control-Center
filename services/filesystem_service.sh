#!/usr/bin/env bash

filesystem_service_create_directory() {

    local directory="$1"

    directory="${directory/#\~/$HOME}"

    local existed=false

    if [[ -e "$directory" ]]; then
        existed=true
    fi

    filesystem_operation_create_directory \
        "$directory" \
    || return 1

    if [[ "$existed" == false ]]; then

        transaction_register \
            "rm -rf \"$directory\""

    fi

}

filesystem_service_exists() {

    local path="$1"

    path="${path/#\~/$HOME}"

    [[ -e "$path" ]]

}

filesystem_service_remove() {

    local path="$1"

    path="${path/#\~/$HOME}"

    filesystem_operation_remove \
        "$path"

}

filesystem_service_copy_directory() {

    local source="$1"
    local destination="$2"

    source="${source/#\~/$HOME}"
    destination="${destination/#\~/$HOME}"

    filesystem_service_exists "$source" \
    || return 1

    filesystem_service_create_directory \
        "$destination" \
    || return 1

    filesystem_operation_copy_directory \
        "$source" \
        "$destination"

}