#!/usr/bin/env bash

manifest_exists() {

    local backup="$1"

    [[ -f "$backup/manifest.txt" ]]

}

manifest_path() {

    local backup="$1"

    echo "$backup/manifest.txt"

}

manifest_value() {

    local manifest="$1"
    local key="$2"

    grep "^${key}=" "$manifest" \
        | head -n1 \
        | cut -d= -f2-

}
manifest_load() {

    local backup="$1"

    local manifest

    manifest="$(manifest_path "$backup")"

    if ! manifest_exists "$backup"; then

        MANIFEST_OS="Unknown"
        MANIFEST_DESKTOP="Unknown"
        MANIFEST_SESSION="Unknown"
        MANIFEST_DATE="Unknown"
        MANIFEST_VERSION="Unknown"
        MANIFEST_HYPRLAND="Unknown"

        return

    fi

    MANIFEST_OS="$(manifest_value "$manifest" OS)"
    MANIFEST_DESKTOP="$(manifest_value "$manifest" Desktop)"
    MANIFEST_SESSION="$(manifest_value "$manifest" Session)"
    MANIFEST_DATE="$(manifest_value "$manifest" Date)"
    MANIFEST_VERSION="$(manifest_value "$manifest" Version)"
    MANIFEST_HYPRLAND="$(manifest_value "$manifest" Hyprland)"

}