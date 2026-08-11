#!/usr/bin/env bash

desktop_package_file() {

    local desktop="$1"

    echo "$PROJECT_ROOT/desktop-packages/$desktop/desktop.conf"

}

desktop_package_exists() {

    local desktop="$1"

    [[ -f "$(desktop_package_file "$desktop")" ]]

}

desktop_package_validate() {

    local desktop="$1"
    local field
    local item
    local source
    local target

    for field in NAME ID VERSION AUTHOR DESCRIPTION
    do
        if [[ -z "${!field:-}" ]]; then
            print_error "Desktop package is missing required field: $field"
            return 1
        fi
    done

    if [[ "$ID" != "$desktop" ]]; then
        print_error "Desktop package ID does not match directory: $ID"
        return 1
    fi

    if [[ -z "${COPY_ITEMS:-}" ]]; then
        return 0
    fi

    if [[ -z "${PACKAGE_ROOT:-}" || "$PACKAGE_ROOT" == /* || "$PACKAGE_ROOT" == *".."* || "$PACKAGE_ROOT" != "desktop-packages/$desktop/"* ]]; then
        print_error "Desktop package payload must be owned by desktop-packages/$desktop/."
        return 1
    fi

    while read -r item
    do
        [[ -z "$item" ]] && continue

        IFS='|' read -r source target <<< "$item"

        if [[ -z "$source" || -z "$target" || "$source" == /* || "$source" == *".."* ]]; then
            print_error "Invalid COPY_ITEMS entry: $item"
            return 1
        fi

        if [[ ! -d "$PROJECT_ROOT/$PACKAGE_ROOT/$source" ]]; then
            print_error "Desktop payload directory not found: $source"
            return 1
        fi
    done <<< "$COPY_ITEMS"

}

desktop_package_is_supported() {

    local distro

    [[ -z "${SUPPORTED_DISTROS:-}" ]] && return 0

    # Ensure package manager detection has run so we can match ID_LIKE
    if ! command -v pm_detect &>/dev/null; then
        return 0
    fi
    [[ -n "${HCC_DISTRO_ID:-}" ]] || pm_detect_distro 2>/dev/null || true

    for distro in $SUPPORTED_DISTROS
    do
        pm_distro_matches "$distro" && return 0
    done

    return 1

}

desktop_package_hook() {

    local desktop="$1"
    local hook="$2"

    echo "$PROJECT_ROOT/desktop-packages/$desktop/hooks/$hook.sh"

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

    desktop_package_validate "$desktop"

}
