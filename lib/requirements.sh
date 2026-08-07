#!/usr/bin/env bash

requirements_file() {

    local plugin="$1"

    echo "$plugin/requirements.conf"

}
requirements_exists() {

    local plugin="$1"

    [[ -f "$(requirements_file "$plugin")" ]]

}
requirements_load() {

    local plugin="$1"

    local file

    file="$(requirements_file "$plugin")"

    if ! requirements_exists "$plugin"; then

        REQUIRE_COMMANDS=""
        REQUIRE_PACKAGES=""
        REQUIRE_SERVICES=""

        return

    fi

    # shellcheck disable=SC1090
    source "$file"

    REQUIRE_COMMANDS="$COMMANDS"
    REQUIRE_PACKAGES="$PACKAGES"
    REQUIRE_SERVICES="$SERVICES"

}