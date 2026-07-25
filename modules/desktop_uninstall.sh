run_desktop_uninstall() {
    local id="$1"
    local plan_file
    local profile_dir
    local has_configs=false
    local has_repos=false
    local has_packages=false
    local answer

    if [[ -z "$id" ]]; then
        print_error "Usage: hcc desktop uninstall <id>"
        print_info "Use: hcc profile list (xem danh sach da cai)"
        return 1
    fi

    if ! profile_registry_exists "$id"; then
        print_error "Profile not found: $id"
        return 1
    fi

    profile_registry_load "$id" || return 1

    print_header "Uninstall Desktop"
    ui_field "Profile" "$PROFILE_NAME ($id)"
    ui_field "Source" "$PROFILE_SOURCE"

    plan_file="$(profile_registry_directory "$id")/ownership.plan"
    profile_dir="$(profile_registry_directory "$id")"

    echo

    if [[ -f "$plan_file" ]]; then
        while IFS='|' read -r ptype parg1 parg2
        do
            [[ -z "$ptype" ]] && continue
            case "$ptype" in
                COPY_DIRECTORY)
                    has_configs=true
                    ;;
                CLONE_REPOSITORY)
                    has_repos=true
                    ;;
            esac
        done < "$plan_file"
    fi

    if [[ "$PROFILE_SOURCE" == "local" ]]; then
        if desktop_package_exists "$id"; then
            desktop_package_load "$id" 2>/dev/null || true
            if [[ -n "${PACMAN_PACKAGES:-}" || -n "${AUR_PACKAGES:-}" ]]; then
                has_packages=true
            fi
        fi
    fi

    print_info "This will:"
    [[ "$has_configs" == true ]] && echo "  - Xoa config files da deploy"
    [[ "$has_repos" == true ]] && echo "  - Xoa git repos da clone"
    [[ "$has_packages" == true ]] && echo "  - Go y xoa packages (PACMAN/AUR)"
    echo "  - Xoa profile registry"
    echo "  - Xoa session + login entry"

    echo

    if [[ -n "${PROFILE_PREVIOUS_SNAPSHOT:-}" && -d "$PROFILE_PREVIOUS_SNAPSHOT" ]]; then
        print_info "Co san snapshot truoc khi cai: $(basename "$PROFILE_PREVIOUS_SNAPSHOT")"
        print_info "Co the restore config files tu snapshot sau khi uninstall."
        echo
    fi

    read -rp "Uninstall '$id'? [y/N]: " answer
    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            if [[ -f "$plan_file" ]]; then
                print_info "Removing deployed files..."
                while IFS='|' read -r ptype parg1 parg2
                do
                    [[ -z "$ptype" ]] && continue
                    case "$ptype" in
                        COPY_DIRECTORY)
                            local dest="${parg2/#\~/$HOME}"
                            if [[ -e "$dest" ]]; then
                                filesystem_service_remove "$dest"
                                print_success "Removed: $dest"
                            else
                                print_info "Not found, skipping: $dest"
                            fi
                            ;;
                        CLONE_REPOSITORY)
                            local repo_dir="${parg2/#\~/$HOME}"
                            if [[ -d "$repo_dir" ]]; then
                                filesystem_service_remove "$repo_dir"
                                print_success "Removed repo: $repo_dir"
                            else
                                print_info "Not found, skipping: $repo_dir"
                            fi
                            ;;
                    esac
                done < "$plan_file"
                echo
            fi

            if [[ "$PROFILE_SOURCE" == "local" ]] && desktop_package_exists "$id"; then
                desktop_package_load "$id" 2>/dev/null || true
                if [[ -n "${PACMAN_PACKAGES:-}" || -n "${AUR_PACKAGES:-}" ]]; then
                    print_warning "Packages duoc cai tu desktop $id:"
                    [[ -n "${PACMAN_PACKAGES:-}" ]] && echo "  PACMAN: $PACMAN_PACKAGES"
                    [[ -n "${AUR_PACKAGES:-}" ]] && echo "  AUR: $AUR_PACKAGES"
                    echo
                    print_info "HCC khong tu dong xoa packages (co the gay hong he thong)."
                    print_info "Xoa thu cong bang: sudo pacman -Rns <package>"
                    echo
                fi
            fi

            if [[ -d "$profile_dir" ]]; then
                filesystem_service_remove "$profile_dir"
                print_success "Removed profile: $id"
            fi

            if desktop_external_exists "$id" 2>/dev/null; then
                local ext_dir
                ext_dir="$(desktop_external_package_dir "$id")"
                if [[ -d "$ext_dir" ]]; then
                    filesystem_service_remove "$ext_dir"
                    print_success "Removed external package: $ext_dir"
                fi
            fi

            local active
            active="$(profile_registry_active)"
            if [[ "$active" == "$id" ]]; then
                rm -f "$(profile_registry_active_file)"
                print_info "Active marker cleared."
            fi

            echo

            if [[ -n "${PROFILE_PREVIOUS_SNAPSHOT:-}" && -d "$PROFILE_PREVIOUS_SNAPSHOT" ]]; then
                print_info "Snapshot available: $(basename "$PROFILE_PREVIOUS_SNAPSHOT")"
                read -rp "Restore config files tu snapshot? [y/N]: " answer
                case "$answer" in
                    [Yy]|[Yy][Ee][Ss])
                        backup_restore_snapshot "$PROFILE_PREVIOUS_SNAPSHOT"
                        print_success "Config files restored from snapshot."
                        ;;
                esac
            fi

            print_success "Uninstall complete: $PROFILE_NAME"
            ;;
        *)
            print_warning "Uninstall cancelled."
            ;;
    esac
}
