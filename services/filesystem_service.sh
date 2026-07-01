#!/usr/bin/env bash

filesystem_copy_directory() {

    local source="$1"

    local destination="$2"

    if [[ ! -d "$source" ]]; then

        print_error "Directory not found: $source"

        return 1

    fi

    mkdir -p "$destination"

    cp -R "$source" "$destination"

}