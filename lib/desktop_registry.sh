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

    if [[ -f "$path/package.toml" ]]; then
        echo "$path/package.toml"
    elif [[ -f "$path/package.conf" ]]; then
        echo "$path/package.conf"
    else
        return 1
    fi
}

desktop_registry_load_package() {
    local id="$1"
    local file
    file="$(desktop_registry_package_file "$id")" || return 1
    unset NAME ID VERSION AUTHOR DESCRIPTION SUPPORTED_DISTROS
    unset PACKAGE_ROOT CONFIG_ROOT ASSETS_ROOT REBOOT_REQUIRED
    unset PACKAGE_ROOT_DIR
    unset PACMAN_PACKAGES AUR_PACKAGES GIT_REPOSITORIES COPY_ITEMS
    unset PACKAGES PACKAGES__LEN AUR__LEN
    unset GIT_REPOSITORIES_0_URL GIT_REPOSITORIES_0_PATH GIT_REPOSITORIES_0_PATH_0
    unset GIT_REPOSITORIES__LEN

    config_read "$file"

    if [[ "$file" == *.toml ]]; then
        config_toml_to_legacy
    fi
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

desktop_external_known_packages() {
    local config_dir="$1"
    case "$config_dir" in
        hypr|hyprland)              echo "hyprland";;
        kitty)                      echo "kitty";;
        waybar)                     echo "waybar";;
        wofi)                       echo "wofi";;
        rofi)                       echo "rofi-wayland";;
        dunst)                      echo "dunst";;
        mako)                       echo "mako";;
        swaync)                     echo "swaync";;
        fish)                       echo "fish";;
        alacritty)                  echo "alacritty";;
        nvim|neovim)                echo "neovim";;
        tmux)                       echo "tmux";;
        btop)                       echo "btop";;
        cava)                       echo "cava";;
        "gtk-3.0")                  echo "gtk3";;
        "gtk-4.0")                  echo "gtk4";;
        starship)                   echo "starship";;
        picom)                      echo "picom";;
        pipewire)                   echo "pipewire wireplumber";;
        swaylock)                   echo "swaylock";;
        waybar-swaync)              echo "waybar swaync";;
        wallpaper|swww)             echo "swww";;
        cliphist)                   echo "cliphist";;
        wlogout)                    echo "wlogout";;
        hyprlock)                   echo "hyprlock";;
        hypridle)                   echo "hypridle";;
        hyprpaper)                  echo "hyprpaper";;
        eww)                        echo "AUR:eww";;
        hyprpanel)                  echo "AUR:hyprpanel";;
        quickshell)                 echo "AUR:quickshell-git";;
        nwg-look)                   echo "AUR:nwg-look";;
        "qt5ct"|"qt6ct")            echo "qt5ct qt6ct";;
        *)                          echo "";;
    esac
}

desktop_external_detect_packages() {
    local dir="$1"
    local pacman=""
    local aur=""
    local seen=""

    local entry already has

    if [[ -d "$dir/.config" ]]; then
        local sub
        for sub in "$dir/.config"/*/
        do
            [[ -d "$sub" ]] || continue
            local name
            name="$(basename "$sub")"
            local pkgs
            pkgs="$(desktop_external_known_packages "$name")"
            [[ -z "$pkgs" ]] && continue
            for entry in $pkgs; do
                case "$entry" in
                    AUR:*)
                        has=false
                        for already in $aur; do
                            [[ "$already" == "${entry#AUR:}" ]] && has=true
                        done
                        [[ "$has" == false ]] && aur="$aur ${entry#AUR:}"
                        ;;
                    *)
                        has=false
                        for already in $pacman; do
                            [[ "$already" == "$entry" ]] && has=true
                        done
                        [[ "$has" == false ]] && pacman="$pacman $entry"
                        ;;
                esac
            done
        done
    fi

    if [[ -d "$dir/hypr" || -d "$dir/.config/hypr" ]]; then
        local hpkgs
        hpkgs="$(desktop_external_known_packages "hypr")"
        for entry in $hpkgs; do
            case "$entry" in
                AUR:*) has=false; for already in $aur; do [[ "$already" == "${entry#AUR:}" ]] && has=true; done; [[ "$has" == false ]] && aur="$aur ${entry#AUR:}" ;;
                *) has=false; for already in $pacman; do [[ "$already" == "$entry" ]] && has=true; done; [[ "$has" == false ]] && pacman="$pacman $entry" ;;
            esac
        done
    fi

    echo "${pacman# }"
    echo "${aur# }"
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

desktop_external_detect_git_repos() {
    local dir="$1"
    local items=""
    local sub

    if [[ -f "$dir/.gitmodules" ]]; then
        local url path
        while IFS= read -r line; do
            if [[ "$line" =~ url[[:space:]]*=[[:space:]]*(.*) ]]; then
                url="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ path[[:space:]]*=[[:space:]]*(.*) ]]; then
                path="${BASH_REMATCH[1]}"
                if [[ -n "$url" && -n "$path" ]]; then
                    items="${items}${url}|~/${path}"$'\n'
                    url=""
                    path=""
                fi
            fi
        done < "$dir/.gitmodules"
    fi

    for sub in "$dir"/*/; do
        [[ -d "$sub/.git" ]] || continue
        local name
        name="$(basename "$sub")"
        local origin
        origin="$(git -C "$sub" config --get remote.origin.url 2>/dev/null)" || continue
        items="${items}${origin}|~/.config/${name}"$'\n'
    done

    [[ -n "$items" ]] && echo "$items"
}

desktop_external_detect_from_scripts() {
    local dir="$1"
    local scripts=("install.sh" "setup.sh" "install" "setup")
    local content=""
    local s
    for s in "${scripts[@]}"; do
        [[ -f "$dir/$s" ]] && content+="$(cat "$dir/$s" 2>/dev/null)"$'\n'
    done
    [[ -z "$content" ]] && { echo; echo; return; }

    local line args word
    local pacman="" aur=""
    local tool=""

    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line//\\/ }"

        if echo "$line" | grep -qE '(pacman|sudo[[:space:]]+pacman)[[:space:]]+-S[^-]'; then
            tool="pacman"
        elif echo "$line" | grep -qE '(yay|paru)[[:space:]]+-S[^-]'; then
            tool="aur"
        else
            continue
        fi

        args="${line#*-S}"
        for word in $args; do
            [[ "$word" =~ ^- ]] && continue
            word="${word//[\";\']/}"
            [[ -z "$word" ]] && continue
            if [[ "$tool" == "pacman" ]]; then
                pacman="$pacman $word"
            else
                aur="$aur $word"
            fi
        done
    done <<< "$content"

    pacman="$(echo "$pacman" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)"
    aur="$(echo "$aur" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)"

    echo "${pacman# }"
    echo "${aur# }"
}

desktop_external_generate_package_conf() {
    local dir="$1"
    local id="$2"
    local name="$3"
    local url="$4"
    local mode="${5:-}"  # "auto" = skip editor prompt
    local copy_items
    copy_items="$(desktop_external_detect_copy_items "$dir")"

    local pacman_pkgs aur_pkgs
    mapfile -t pkg_lines < <(desktop_external_detect_packages "$dir")
    pacman_pkgs="${pkg_lines[0]:-}"
    aur_pkgs="${pkg_lines[1]:-}"

    mapfile -t script_lines < <(desktop_external_detect_from_scripts "$dir")
    local pacman_scr="${script_lines[0]:-}"
    local aur_scr="${script_lines[1]:-}"

    pacman_pkgs="$(echo "$pacman_pkgs $pacman_scr" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)"
    aur_pkgs="$(echo "$aur_pkgs $aur_scr" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)"

    local git_items
    git_items="$(desktop_external_detect_git_repos "$dir")"

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
PACMAN_PACKAGES="$pacman_pkgs"
AUR_PACKAGES="$aur_pkgs"
GIT_REPOSITORIES="$git_items"
COPY_ITEMS="$copy_items"
EOF

    print_success "Da tao package.conf: $dir/package.conf"
    echo
    if [[ -n "$pacman_pkgs" ]]; then
        print_info "Tu dong phat hien PACMAN: $pacman_pkgs"
    fi
    if [[ -n "$aur_pkgs" ]]; then
        print_info "Tu dong phat hien AUR: $aur_pkgs"
    fi
    if [[ -n "$git_items" ]]; then
        print_info "Tu dong phat hien GIT repos"
    fi

    local has_any=false
    [[ -n "$pacman_pkgs" || -n "$aur_pkgs" || -n "$git_items" || -n "$copy_items" ]] && has_any=true

    if [[ "$mode" == "auto" ]]; then
        if [[ "$has_any" == true ]]; then
            return 0
        fi
        print_warning "Khong the tu dong phat hien. Can nhap tay."
        return 1
    fi

    if [[ "$has_any" == false ]]; then
        print_warning "Khong the tu dong phat hien. Can nhap tay."
    fi
    echo
    print_warning "Muon kiem tra va chinh sua package.conf?"
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

desktop_external_show_package_conf_help() {
    print_header "Huong dan dinh dang package.conf"
    echo
    print_info "package.conf la file cau hinh mo ta desktop package cho HCC."
    echo
    echo "  NAME=\"Ten Desktop\""
    echo "  ID=\"ten-desktop\""
    echo "  VERSION=\"0.1.0\""
    echo "  AUTHOR=\"author-name\""
    echo "  DESCRIPTION=\"Mo ta ngan\""
    echo "  SUPPORTED_DISTROS=\"\""
    echo "  PACKAGE_ROOT=\".\""
    echo "  REBOOT_REQUIRED=false"
    echo "  PACMAN_PACKAGES=\"pkg1 pkg2\""
    echo "  AUR_PACKAGES=\"pkg1 pkg2\""
    echo "  GIT_REPOSITORIES=\"url|~/.config/name\""
    echo "  COPY_ITEMS=\"src|dest\""
    echo
    print_info "COPY_ITEMS: source|destination, moi dong mot entry"
    echo "  Source: duong dan relative trong repo (vd: .config/hypr)"
    echo "  Dest: duong dan tuyet doi (vd: ~/.config/hypr)"
    echo
    print_info "Vi du day du:"
    echo "  NAME=\"My Hyprland Desktop\""
    echo "  ID=\"my-desktop\""
    echo "  VERSION=\"1.0.0\""
    echo "  AUTHOR=\"username\""
    echo "  DESCRIPTION=\"A beautiful Hyprland setup\""
    echo "  PACMAN_PACKAGES=\"hyprland kitty waybar\""
    echo "  AUR_PACKAGES=\"hyprpanel-git\""
    echo "  COPY_ITEMS=\".config/hypr|~/.config/hypr"
    echo "  .config/kitty|~/.config/kitty\""
    echo
}

desktop_external_detect_from_home_config() {
    local seen_dirs="" pacman="" aur=""
    local sub
    for sub in "$HOME/.config"/*/
    do
        [[ -d "$sub" ]] || continue
        local name
        name="$(basename "$sub")"
        local pkgs
        pkgs="$(desktop_external_known_packages "$name")"
        [[ -z "$pkgs" ]] && continue
        seen_dirs="$seen_dirs $name"
        local entry already
        for entry in $pkgs; do
            case "$entry" in
                AUR:*)
                    local aur_name="${entry#AUR:}"
                    local has=false
                    for already in $aur; do [[ "$already" == "$aur_name" ]] && has=true; done
                    [[ "$has" == false ]] && aur="$aur $aur_name"
                    ;;
                *)
                    local has=false
                    for already in $pacman; do [[ "$already" == "$entry" ]] && has=true; done
                    [[ "$has" == false ]] && pacman="$pacman $entry"
                    ;;
            esac
        done
    done
    echo "${pacman# }"
    echo "${aur# }"
    echo "${seen_dirs# }"
}

desktop_external_run_script_and_detect() {
    local dir="$1"
    local id="$2"
    local name="$3"
    local url="$4"

    local script_names=("install.sh" "setup.sh" "bootstrap.sh" "install" "setup")
    local found=()
    local s
    for s in "${script_names[@]}"; do
        [[ -f "$dir/$s" ]] && found+=("$s")
    done

    echo
    if [[ ${#found[@]} -eq 0 ]]; then
        print_warning "Khong tim thay install script nao trong repo."
        echo
        local custom_cmd
        read -rp "Nhap lenh cai dat (hoac Enter de bo qua): " custom_cmd
        [[ -z "$custom_cmd" ]] && return 1
        found=("$custom_cmd")
    else
        print_info "Cac script cai dat co san:"
        local i
        for i in "${!found[@]}"; do
            echo "  $((i+1))) ${found[$i]}"
        done
        echo "  c) Nhap lenh tuy chinh"
        echo "  0) Bo qua"
        echo
        local choice
        read -rp "Chon script [1-${#found[@]}/c/0] (Enter=1): " choice
        case "$choice" in
            0|q|cancel) return 1 ;;
            c|custom)
                local custom_cmd
                read -rp "Nhap lenh cai dat: " custom_cmd
                [[ -z "$custom_cmd" ]] && return 1
                found=("$custom_cmd")
                ;;
            *)
                local idx=$((choice-1))
                [[ "$idx" -ge 0 && "$idx" -lt "${#found[@]}" ]] || idx=0
                found=("${found[$idx]}")
                ;;
        esac
    fi

    local cmd="${found[0]}"
    local log_file="$dir/.hcc-install-log"
    print_info "Dang chay: $cmd"
    print_info "Log: $log_file"
    echo

    local pre_file="$dir/.hcc-pre-config"
    local post_file="$dir/.hcc-post-config"
    find "$HOME/.config" -maxdepth 3 -type f -o -type l 2>/dev/null | sort > "$pre_file"

    (
        cd "$dir" || exit 1
        if [[ -f "$dir/$cmd" ]]; then
            bash "$dir/$cmd" 2>&1
        else
            bash -c "$cmd" 2>&1
        fi
    ) | tee "$log_file"
    local exit_code=${PIPESTATUS[0]}

    find "$HOME/.config" -maxdepth 3 -type f -o -type l 2>/dev/null | sort > "$post_file"

    if [[ "$exit_code" -ne 0 ]]; then
        print_warning "Script chay voi exit code $exit_code."
    fi

    if [[ -f "$log_file" ]]; then
        local pkg_errors mirror_errors other_errors
        pkg_errors="$(grep -c 'failed to commit transaction\|Errors occurred, no packages\|error.*install.*package' "$log_file" 2>/dev/null || true)"
        mirror_errors="$(grep -c 'failed retrieving file\|failed to download\|404\|Cannot resume' "$log_file" 2>/dev/null || true)"
        other_errors="$(grep -ci 'error:' "$log_file" 2>/dev/null || true)"
        echo
        if [[ "$pkg_errors" -gt 0 ]]; then
            print_error "Phat hien $pkg_errors package installation failure(s) - CAN NHAP TAY SAU"
            print_warning "Chay: yay -S <package> de cai la nhung package bi loi"
        fi
        if [[ "$mirror_errors" -gt 0 ]]; then
            print_warning "$mirror_errors mirror download error(s) (404/thu hoi) - thuong do mirror chua dong bo"
            print_info "Khong nguy hiem, thu lai sau: yay -S <package>"
        fi
        if [[ "$other_errors" -gt 0 && "$pkg_errors" -eq 0 ]]; then
            print_warning "$other_errors error(s) khac trong log"
        fi
        if [[ "$pkg_errors" -eq 0 && "$mirror_errors" -eq 0 ]]; then
            print_success "Khong phat hien loi nghiem trong."
        fi
        echo
    fi

    local new_files
    new_files="$(diff "$pre_file" "$post_file" 2>/dev/null | grep '^>' | sed 's/^> //')"
    rm -f "$pre_file" "$post_file"

    if [[ -n "$new_files" ]]; then
        echo
        print_info "Phat hien file cau hinh moi:"
        echo "$new_files" | head -20
        local count
        count="$(echo "$new_files" | wc -l)"
        [[ "$count" -gt 20 ]] && echo "  ... va $((count-20)) file khac"
    fi

    echo
    print_info "Dang phan tich lai repo de tao package.conf..."
    if desktop_external_generate_package_conf "$dir" "$id" "$name" "$url" "auto"; then
        print_success "Da tao package.conf tu repo."
        return 0
    fi

    print_info "Repo khong co cau truc .config/, thu phat hien tu $HOME/.config..."
    mapfile -t home_lines < <(desktop_external_detect_from_home_config)
    local pacman_home="${home_lines[0]:-}"
    local aur_home="${home_lines[1]:-}"
    local config_dirs="${home_lines[2]:-}"

    if [[ -n "$config_dirs" ]]; then
        local author
        author="$(basename "$(dirname "$url")")"
        local dir_out
        dir_out="$(desktop_external_package_dir "$id")"
        mkdir -p "$dir_out" 2>/dev/null || true

        cat > "$dir_out/package.conf" << EOF
NAME="$name (post-install)"
ID="$id"
VERSION="0.1.0"
AUTHOR="$author"
DESCRIPTION="Auto-detected from $HOME/.config after running install script"
SUPPORTED_DISTROS=""
PACKAGE_ROOT="."
REBOOT_REQUIRED=false
PACMAN_PACKAGES="$pacman_home"
AUR_PACKAGES="$aur_home"
GIT_REPOSITORIES=""
COPY_ITEMS=""
EOF

        print_success "Da tao package.conf tu $HOME/.config: $dir_out/package.conf"
        if [[ -n "$pacman_home" ]]; then
            print_info "Phat hien PACMAN: $pacman_home"
        fi
        if [[ -n "$aur_home" ]]; then
            print_info "Phat hien AUR: $aur_home"
        fi
        return 0
    fi

    print_warning "Van khong the tu dong phat hien. Can cau hinh tay."
    return 1
}

desktop_external_edit_package_conf() {
    local id="$1"
    local dir
    dir="$(desktop_external_package_dir "$id")"
    local editor="${EDITOR:-nano}"

    print_info "Dang mo: $dir/package.conf"
    if command -v "$editor" &>/dev/null; then
        "$editor" "$dir/package.conf"
    elif command -v "nano" &>/dev/null; then
        nano "$dir/package.conf"
    elif command -v "vi" &>/dev/null; then
        vi "$dir/package.conf"
    else
        print_warning "Khong tim thay trinh soan thao. Edit thu cong: $dir/package.conf"
        return 1
    fi
}

desktop_external_add() {
    local url="$1"
    local id="$2"
    local name="$3"
    local use_ai="${4:-}"
    local dir
    dir="$(desktop_external_package_dir "$id")"

    if desktop_external_exists "$id"; then
        if [[ "$use_ai" == "ai" ]]; then
            print_info "Dang phan tich lai repo bang AI..."
            if desktop_ai_analyze_repo "$dir" "$url" "$id" "$name"; then
                print_success "AI da tao lai package.conf"
                return 0
            fi
            print_warning "AI khong thanh cong, mo editor..."
        fi
        print_warning "External package '$id' da ton tai: $dir"
        echo
        local answer
        read -rp "Chinh sua package.conf? [Y/n]: " answer
        case "$answer" in
            [Nn]|[Nn][Oo])
                print_info "Dung: hcc desktop install $id"
                return 0
                ;;
        esac
        desktop_external_edit_package_conf "$id"
        return 0
    fi

    mkdir -p "$dir" || return 1

    print_info "Cloning external repo to: $dir"
    git clone --depth 1 "$url" "$dir" || {
        rm -rf "$dir"
        print_error "Failed to clone repository"
        return 1
    }

    if [[ "$use_ai" == "ai" ]]; then
        if desktop_ai_analyze_repo "$dir" "$url" "$id" "$name"; then
            return 0
        fi
        print_warning "AI khong thanh cong, dung co che auto-detect thay the."
    fi

    desktop_external_generate_package_conf "$dir" "$id" "$name" "$url"
}

#
# AI-powered package.conf generation (Google Gemini)
#

HCC_AI_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hcc/ai.conf"

desktop_ai_load_key() {
    HCC_AI_API_KEY="${HCC_AI_API_KEY:-}"
    [[ -n "$HCC_AI_API_KEY" ]] && return 0
    [[ -f "$HCC_AI_CONFIG_FILE" ]] || return 1
    source "$HCC_AI_CONFIG_FILE"
    HCC_AI_API_KEY="${HCC_AI_API_KEY:-}"
    [[ -n "$HCC_AI_API_KEY" ]]
}

desktop_ai_remove_key() {
    if [[ ! -f "$HCC_AI_CONFIG_FILE" ]]; then
        print_info "Khong co API key nao duoc luu."
        return 0
    fi
    local answer
    read -rp "Xoa API key tai $HCC_AI_CONFIG_FILE? [y/N]: " answer
    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            rm -f "$HCC_AI_CONFIG_FILE"
            HCC_AI_API_KEY=""
            print_success "Da xoa API key."
            ;;
        *)
            print_info "Huy xoa."
            ;;
    esac
}

desktop_ai_setup() {
    if desktop_ai_load_key; then
        return 0
    fi

    echo
    print_warning "HCC co the dung Google Gemini (free) de tu dong phan tich repo"
    print_info "va tao package.conf hoan chinh."
    echo
    print_info "Lay API key mien phi tai: https://aistudio.google.com/apikey"
    echo

    local answer
    read -rp "Nhap API key (hoac Enter de bo qua): " key
    [[ -z "$key" ]] && return 1

    mkdir -p "$(dirname "$HCC_AI_CONFIG_FILE")" 2>/dev/null
    printf 'HCC_AI_API_KEY=%q\n' "$key" > "$HCC_AI_CONFIG_FILE"
    HCC_AI_API_KEY="$key"
    print_success "Da luu API key vao $HCC_AI_CONFIG_FILE"
    return 0
}

desktop_ai_analyze_repo() {
    local dir="$1"
    local url="$2"
    local id="$3"
    local name="$4"

    desktop_ai_load_key || {
        desktop_ai_setup || return 1
    }

    command -v jq &>/dev/null || {
        print_error "Can jq de xu ly JSON. Cai dat: sudo pacman -S jq"
        return 1
    }

    print_info "Dang phan tich repo bang AI..."

    local readme=""
    if [[ -f "$dir/README.md" ]]; then
        readme="$(head -200 "$dir/README.md" 2>/dev/null)"
    elif [[ -f "$dir/README" ]]; then
        readme="$(head -200 "$dir/README" 2>/dev/null)"
    fi

    local tree
    tree="$(find "$dir" -maxdepth 4 -not -path '*.git/*' -not -name '.git' -not -path "$dir" 2>/dev/null | head -100 | sed "s|$dir/||" | sed "s|$dir||")"

    local scripts=""
    if [[ -f "$dir/install.sh" ]]; then
        scripts="install.sh:$(head -50 "$dir/install.sh" 2>/dev/null)"
    fi
    if [[ -f "$dir/setup.sh" ]]; then
        scripts="${scripts}"$'\n'"setup.sh:$(head -50 "$dir/setup.sh" 2>/dev/null)"
    fi

    local prompt_text
    prompt_text=$(cat << PROMPT
You are analyzing a dotfiles/Linux desktop configuration repository for Hyprland Control Center (HCC) on Arch Linux.

Repo: $url
Files:
$tree

README:
${readme:-none}

Scripts:
${scripts:-none}

Based ONLY on what you see, output a package.conf with these exact fields (one per line, NAME=VALUE format):

NAME=<human readable name>
DESCRIPTION=<one line description>
PACMAN_PACKAGES=<space separated arch packages, or empty>
AUR_PACKAGES=<space separated aur packages, or empty>
GIT_REPOSITORIES=<leave empty>
COPY_ITEMS=<path/in/repo|~/.config/dest on each line, use \n between multiple, or empty>

Rules:
- Only include packages you are sure about
- If .config/hypr/ exists -> hyprland
- If .config/kitty/ exists -> kitty
- If a config dir maps to a known package, include it
- If no packages are clearly needed, leave PACMAN_PACKAGES empty
- Output ONLY the field lines, nothing else
PROMPT
)

    local json_data
    json_data="$(printf '%s' "$prompt_text" | jq -Rs '{contents: [{parts: [{text: .}]}]}')" || {
        print_error "Loi tao JSON payload"
        return 1
    }

    local response
    response=$(curl -s -w "\n%{http_code}" \
        -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$HCC_AI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$json_data" 2>/dev/null)

    local http_code
    http_code="$(echo "$response" | tail -1)"
    local body
    body="$(echo "$response" | sed '$d')"

    [[ "$http_code" != "200" ]] && {
        print_error "AI API error (HTTP $http_code)"
        echo "$body" | head -3 1>&2
        return 1
    }

    local text
    text="$(echo "$body" | jq -r '.candidates[0].content.parts[0].text // empty' 2>/dev/null)"
    [[ -z "$text" ]] && {
        print_error "AI khong tra ve ket qua"
        return 1
    }

    local dir_out
    dir_out="$(desktop_external_package_dir "$id")"
    mkdir -p "$dir_out" || return 1

    local author
    author="$(basename "$(dirname "$url")")"

    local f_name f_desc f_pacman f_aur f_copy
    f_name="$(echo "$text" | grep -i '^NAME=' | head -1 | cut -d= -f2- | head -c 100)"
    f_desc="$(echo "$text" | grep -i '^DESCRIPTION=' | head -1 | cut -d= -f2- | head -c 200)"
    f_pacman="$(echo "$text" | grep -i '^PACMAN_PACKAGES=' | head -1 | cut -d= -f2-)" 
    f_aur="$(echo "$text" | grep -i '^AUR_PACKAGES=' | head -1 | cut -d= -f2-)"
    f_copy="$(echo "$text" | grep -i '^COPY_ITEMS=' | head -1 | cut -d= -f2-)"

    f_pacman="${f_pacman:-}"
    f_aur="${f_aur:-}"
    f_copy="${f_copy:-}"

    cat > "$dir_out/package.conf" << EOF
NAME="${f_name:-$name}"
ID="$id"
VERSION="0.1.0"
AUTHOR="$author"
DESCRIPTION="${f_desc:-External package from $url}"
SUPPORTED_DISTROS=""
PACKAGE_ROOT="."
REBOOT_REQUIRED=false
PACMAN_PACKAGES="$f_pacman"
AUR_PACKAGES="$f_aur"
GIT_REPOSITORIES=""
COPY_ITEMS="$f_copy"
EOF

    print_success "AI da tao package.conf: $dir_out/package.conf"
    return 0
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

#
# Community registry discovery
#

HCC_COMMUNITY_REGISTRY_URL="${HCC_COMMUNITY_REGISTRY_URL:-https://raw.githubusercontent.com/hyprland-control-center/community-registry/main/registry.txt}"

desktop_registry_community_fetch() {
    local keyword="${1:-}"

    command -v curl &>/dev/null || {
        print_error "Can curl de tai community registry. Cai dat: sudo pacman -S curl"
        return 1
    }

    print_info "Dang tai community registry..."
    print_info "  $HCC_COMMUNITY_REGISTRY_URL"
    echo

    local data
    data="$(curl -sL --connect-timeout 10 "$HCC_COMMUNITY_REGISTRY_URL" 2>/dev/null)" || {
        print_warning "Khong the tai community registry."
        print_info "Kiem tra ket noi mang hoac cau hinh:"
        print_info "  export HCC_COMMUNITY_REGISTRY_URL=<url>"
        return 1
    }

    local found=0
    local line name url desc
    while IFS='|' read -r name url desc
    do
        [[ -z "$name" || "$name" == "#"* ]] && continue
        if [[ -n "$keyword" ]]; then
            echo "$name" | grep -qi "$keyword" && true || \
            echo "$url" | grep -qi "$keyword" && true || \
            echo "$desc" | grep -qi "$keyword" && true || continue
        fi
        ((found++))
        printf "  %2d) %s\n" "$found" "$name"
        printf "      URL: %s\n" "$url"
        printf "      %s\n" "$desc"
        echo
    done <<< "$data"

    if [[ "$found" -eq 0 ]]; then
        if [[ -n "$keyword" ]]; then
            print_info "Khong tim thay desktop nao voi tu khoa: $keyword"
        else
            print_info "Community registry trong hoac khong tai duoc."
        fi
        return 1
    fi

    print_success "Tim thay $found desktop(s) trong community registry"
    echo
    print_info "Cai dat: hcc desktop install <url>"
    return 0
}

desktop_registry_community_search() {
    local keyword="$1"

    if [[ -z "$keyword" ]]; then
        print_error "Nhap tu khoa tim kiem."
        print_info "Su dung: hcc desktop search <keyword>"
        return 1
    fi

    desktop_registry_community_fetch "$keyword"
}
