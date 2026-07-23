desktop_registry_root() {
    echo "$PROJECT_ROOT/desktops"
}

desktop_registry_file() {
    echo "$(desktop_registry_root)/registry.conf"
}

desktop_registry_load() {
    local file
    file="$(desktop_registry_file)"
    [[ -f "$file" ]] || return 1
    unset DESKTOP_REGISTRY_IDS
    # shellcheck disable=SC1090
    source "$file"
}

desktop_registry_list() {
    local root
    root="$(desktop_registry_root)"
    [[ -d "$root" ]] || return 0
    desktop_registry_load || return 0
    local id
    for id in $DESKTOP_REGISTRY_IDS
    do
        [[ -n "$id" ]] && echo "$id"
    done
}

desktop_registry_exists() {
    local id="$1"
    [[ -z "$id" ]] && return 1
    desktop_registry_load || return 1
    local entry
    for entry in $DESKTOP_REGISTRY_IDS
    do
        [[ "$entry" == "$id" ]] && return 0
    done
    return 1
}

desktop_registry_package_path() {
    local id="$1"
    desktop_registry_exists "$id" || return 1
    local key
    key="$(printf '%s' "$id" | tr '[:lower:]' '[:upper:]' | tr '-' '_')"
    local var="DESKTOP_REGISTRY_${key}_PATH"
    local path="${!var}"
    [[ -n "$path" ]] || return 1
    echo "$PROJECT_ROOT/$path"
}

desktop_registry_package_file() {
    local id="$1"
    local path
    path="$(desktop_registry_package_path "$id")" || return 1
    echo "$path/package.conf"
}

desktop_registry_load_package() {
    local id="$1"
    local file
    file="$(desktop_registry_package_file "$id")" || return 1
    [[ -f "$file" ]] || return 1
    unset NAME ID VERSION AUTHOR DESCRIPTION SUPPORTED_DISTROS
    unset PACKAGE_ROOT CONFIG_ROOT ASSETS_ROOT REBOOT_REQUIRED
    unset PACKAGE_ROOT_DIR
    unset PACMAN_PACKAGES AUR_PACKAGES GIT_REPOSITORIES COPY_ITEMS
    # shellcheck disable=SC1090
    source "$file"
}

desktop_registry_validate() {
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

    if [[ -z "${PACKAGE_ROOT:-}" || "$PACKAGE_ROOT" == /* || "$PACKAGE_ROOT" == *".."* || "$PACKAGE_ROOT" != "desktops/$desktop/"* ]]; then
        print_error "Desktop package payload must be owned by desktops/$desktop/."
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

desktop_registry_validate_package() {
    local desktop="$1"
    desktop_registry_load_package "$desktop" || return 1
    desktop_registry_validate "$desktop"
}

#
# External / URL-based package loading
#

desktop_package_load_from_dir() {
    local dir="$1"
    local file="$dir/package.conf"
    [[ -f "$file" ]] || return 1
    unset NAME ID VERSION AUTHOR DESCRIPTION SUPPORTED_DISTROS
    unset PACKAGE_ROOT CONFIG_ROOT ASSETS_ROOT REBOOT_REQUIRED
    unset PACMAN_PACKAGES AUR_PACKAGES GIT_REPOSITORIES COPY_ITEMS
    unset HCC_MANIFEST_VERSION REPOSITORY_ID REPOSITORY_NAME
    unset REPOSITORY_VERSION REPOSITORY_AUTHOR REPOSITORY_DESCRIPTION
    # shellcheck disable=SC1090
    source "$file"
    PACKAGE_ROOT_DIR="$dir"
}

desktop_package_validate_external() {
    local dir="$1"
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

    if [[ -z "${COPY_ITEMS:-}" ]]; then
        return 0
    fi

    local base="${PACKAGE_ROOT_DIR:-$dir}"
    local pkg_root="${PACKAGE_ROOT:-.}"

    if [[ "$pkg_root" == /* || "$pkg_root" == *".."* ]]; then
        print_error "Desktop package payload path is invalid: $pkg_root"
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

        if [[ ! -d "$base/$pkg_root/$source" ]]; then
            print_error "Desktop payload directory not found: $source"
            return 1
        fi
    done <<< "$COPY_ITEMS"
}

desktop_package_validate_and_load_external() {
    local dir="$1"
    if [[ -f "$dir/hcc.manifest" ]]; then
        repository_manifest_load "$dir" || {
            print_error "Invalid hcc.manifest in external repository"
            return 1
        }
        repository_manifest_validate || {
            print_error "hcc.manifest validation failed"
            return 1
        }
    fi
    desktop_package_load_from_dir "$dir" || {
        print_error "No package.conf found in external repository"
        return 1
    }
    desktop_package_validate_external "$dir" || return 1
}
