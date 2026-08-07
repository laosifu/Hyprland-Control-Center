#!/usr/bin/env bash

profile_registry_root() {

    echo "${HCC_DATA_DIR:-$HOME/.local/share/hcc}/profiles"

}

profile_registry_active_file() {

    echo "$(profile_registry_root)/active"

}

profile_registry_validate_id() {

    [[ "$1" =~ ^[a-z0-9][a-z0-9_-]*$ ]]

}

profile_registry_directory() {

    local id="$1"

    echo "$(profile_registry_root)/$id"

}

profile_registry_exists() {

    [[ -f "$(profile_registry_directory "$1")/profile.conf" ]]

}

profile_registry_register() {

    local id="$1"
    local name="$2"
    local version="$3"
    local source="${4:-local}"
    local snapshot="${5:-}"
    local root
    local directory

    profile_registry_validate_id "$id" || return 1

    root="$(profile_registry_root)"
    directory="$(profile_registry_directory "$id")"

    mkdir -p "$directory" || return 1

    printf 'PROFILE_ID=%q\nPROFILE_NAME=%q\nPROFILE_VERSION=%q\nPROFILE_SOURCE=%q\nPROFILE_PREVIOUS_SNAPSHOT=%q\nPROFILE_INSTALLED_AT=%q\n' \
        "$id" "$name" "$version" "$source" "$snapshot" "$(date -Iseconds)" \
        > "$directory/profile.conf"

}

profile_registry_activate() {

    local id="$1"
    local root

    profile_registry_exists "$id" || return 1

    root="$(profile_registry_root)"
    mkdir -p "$root" || return 1
    printf '%s\n' "$id" > "$(profile_registry_active_file)"

}

profile_registry_active() {

    local file

    file="$(profile_registry_active_file)"
    [[ -f "$file" ]] || return 0
    head -n 1 "$file"

}

profile_registry_list() {

    local root

    root="$(profile_registry_root)"
    [[ -d "$root" ]] || return 0

    find "$root" -mindepth 2 -maxdepth 2 -name profile.conf -print | sort

}

profile_registry_load() {

    local id="$1"
    local file

    file="$(profile_registry_directory "$id")/profile.conf"
    [[ -f "$file" ]] || return 1

    unset PROFILE_ID PROFILE_NAME PROFILE_VERSION PROFILE_SOURCE PROFILE_PREVIOUS_SNAPSHOT PROFILE_INSTALLED_AT
    # shellcheck disable=SC1090
    source "$file"

}
