#!/usr/bin/env bash

list_themes() {

    find \
        "$PROJECT_ROOT/themes" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        | sort

}

theme_directory() {

    local name="$1"

    echo "$PROJECT_ROOT/themes/$name"

}

theme_directory_exists() {

    local name="$1"

    [[ -d "$(theme_directory "$name")" ]]

}

theme_config_file() {

    local theme="$1"

    echo "$theme/theme.conf"

}

theme_exists() {

    local theme="$1"

    [[ -f "$(theme_config_file "$theme")" ]]

}

theme_load() {

    local theme="$1"

    local file

    file="$(theme_config_file "$theme")"

    if ! theme_exists "$theme"; then
        return 1
    fi

    unset NAME
    unset VERSION
    unset AUTHOR
    unset DESCRIPTION

    # shellcheck disable=SC1090
    source "$file"

}

theme_install_script() {

    local theme="$1"

    echo "$theme/install.sh"

}

theme_install_script_exists() {

    local theme="$1"

    [[ -x "$(theme_install_script "$theme")" ]]

}
theme_uninstall_script() {

    local theme="$1"

    echo "$theme/uninstall.sh"

}

theme_manifest_file() {

    local theme="$1"

    echo "$theme/manifest.txt"

}

theme_validate() {

    local theme="$1"

    [[ -f "$(theme_config_file "$theme")" ]] || return 1

    [[ -x "$(theme_install_script "$theme")" ]] || return 1

    [[ -x "$(theme_uninstall_script "$theme")" ]] || return 1

    [[ -f "$(theme_manifest_file "$theme")" ]] || return 1

}