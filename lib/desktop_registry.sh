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

#
# External desktop registry (user-managed, $HOME based)
#

HCC_EXTERNAL_DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/hcc/desktops"

desktop_external_root() {
    mkdir -p "$HCC_EXTERNAL_DESKTOP_DIR" 2>/dev/null || true
    echo "$HCC_EXTERNAL_DESKTOP_DIR"
}

desktop_external_package_dir() {
    local id="$1"
    echo "$(desktop_external_root)/$id"
}

desktop_external_package_file() {
    local id="$1"
    echo "$(desktop_external_package_dir "$id")/package.conf"
}

desktop_external_list() {
    local root
    root="$(desktop_external_root)"
    [[ -d "$root" ]] || return 0
    local dir
    for dir in "$root"/*/
    do
        [[ -f "$dir/package.conf" ]] || continue
        basename "$dir"
    done
}

desktop_external_exists() {
    local id="$1"
    [[ -z "$id" ]] && return 1
    [[ -f "$(desktop_external_package_file "$id")" ]]
}

desktop_external_load_package() {
    local id="$1"
    local dir
    dir="$(desktop_external_package_dir "$id")"
    [[ -f "$dir/package.conf" ]] || return 1
    desktop_package_load_from_dir "$dir" || return 1
    desktop_package_validate_external "$dir" || return 1
}

desktop_external_detect_copy_items() {
    local dir="$1"
    local items=""

    if [[ -d "$dir/.config" ]]; then
        local sub
        for sub in "$dir/.config"/*/
        do
            [[ -d "$sub" ]] || continue
            local name
            name="$(basename "$sub")"
            items="${items}.config/${name}|~/.config/${name}"$'\n'
        done
    fi

    if [[ -d "$dir/hypr" ]]; then
        items="${items}hypr|~/.config/hypr"$'\n'
    fi

    if [[ -d "$dir/.local/share" ]]; then
        items="${items}.local/share|~/.local/share"$'\n'
    fi

    [[ -n "$items" ]] && echo "$items"
}

desktop_external_generate_package_conf() {
    local dir="$1"
    local id="$2"
    local name="$3"
    local url="$4"
    local copy_items
    copy_items="$(desktop_external_detect_copy_items "$dir")"

    local editor="${EDITOR:-nano}"

    cat > "$dir/package.conf" << EOF
NAME="$name"
ID="$id"
VERSION="0.1.0"
AUTHOR="$(basename "$(dirname "$url")")"
DESCRIPTION="External package from $url"
SUPPORTED_DISTROS=""
PACKAGE_ROOT="."
REBOOT_REQUIRED=false
PACMAN_PACKAGES=""
AUR_PACKAGES=""
GIT_REPOSITORIES=""
COPY_ITEMS="$copy_items"
EOF

    print_success "Da tao package.conf: $dir/package.conf"
    echo
    print_info "Cac truong can quan tam:"
    print_info "  PACMAN_PACKAGES   — Goi can cai tu Pacman (vd: hyprland kitty waybar)"
    print_info "  AUR_PACKAGES      — Goi can cai tu AUR (vd: hyprpicker-git)"
    print_info "  GIT_REPOSITORIES  — Repo can clone (vd: url|~/.config/ten-repo)"
    print_info "  COPY_ITEMS        — Thu muc config can copy (da tu dong phat hien)"
    echo
    print_warning "Muon chinh sua package.conf truoc khi cai?"
    local answer
    read -rp "Mo trinh soan thao? [Y/n]: " answer
    case "$answer" in
        [Nn]|[Nn][Oo])
            return 0
            ;;
    esac

    if command -v "$editor" &>/dev/null; then
        "$editor" "$dir/package.conf"
    elif command -v "nano" &>/dev/null; then
        nano "$dir/package.conf"
    elif command -v "vi" &>/dev/null; then
        vi "$dir/package.conf"
    else
        print_warning "Khong tim thay trinh soan thao. Edit thu cong: $dir/package.conf"
    fi
}

desktop_external_add() {
    local url="$1"
    local id="$2"
    local name="$3"
    local dir
    dir="$(desktop_external_package_dir "$id")"

    if desktop_external_exists "$id"; then
        print_warning "External package '$id' da ton tai: $dir"
        print_info "Dung: hcc desktop install $id"
        return 1
    fi

    mkdir -p "$dir" || return 1

    print_info "Cloning external repo to: $dir"
    git clone --depth 1 "$url" "$dir" || {
        rm -rf "$dir"
        print_error "Failed to clone repository"
        return 1
    }

    desktop_external_generate_package_conf "$dir" "$id" "$name" "$url"

    print_success "Da them external desktop: $id"
    echo
    print_info "Cai dat bang: hcc desktop install $id"
}

desktop_external_remove() {
    local id="$1"
    local dir
    dir="$(desktop_external_package_dir "$id")"

    [[ -d "$dir" ]] || {
        print_error "External package not found: $id"
        return 1
    }

    rm -rf "$dir"
    print_success "Da xoa external desktop: $id"
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

    desktop_external_list
}
