#!/usr/bin/env bash

filesystem_copy_directory() {

    local source="$1"
    local destination="$2"

    if [[ ! -d "$source" ]]; then

        return 1

    fi

    cp -rf "$source" "$destination"

}

filesystem_copy_file() {

    local source="$1"
    local destination="$2"

    if [[ ! -f "$source" ]]; then

        return 1

    fi

    cp -f "$source" "$destination"

}