#!/usr/bin/env bash

desktop_package_file() {

    local desktop="$1"

    echo "$PROJECT_ROOT/desktop-packages/$desktop/desktop.conf"

}

desktop_package_exists() {

    local desktop="$1"

    [[ -f "$(desktop_package_file "$desktop")" ]]

}

desktop_package_load() {

    local desktop="$1"

    local file

    file="$(desktop_package_file "$desktop")"

    if ! desktop_package_exists "$desktop"; then

        return 1

    fi

    # shellcheck disable=SC1090
    source "$file"

}