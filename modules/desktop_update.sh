run_desktop_update() {
    local id="$1"

    if [[ -z "$id" ]]; then
        print_error "Usage: hcc desktop update <id>"
        print_info "Use: hcc profile list (xem danh sach da cai)"
        return 1
    fi

    if ! profile_registry_exists "$id"; then
        print_error "Profile not found: $id"
        return 1
    fi

    profile_registry_load "$id" || return 1

    print_header "Update Desktop"
    ui_field "Profile" "$PROFILE_NAME ($id)"
    ui_field "Source" "${PROFILE_SOURCE:-local}"
    echo

    local source="${PROFILE_SOURCE:-local}"

    if [[ "$source" == https://* || "$source" == http://* || "$source" == git@* ]]; then
        print_info "Source is a remote repository. Pulling latest..."
        local ext_dir
        ext_dir="$(desktop_external_package_dir "$id")"
        if [[ -d "$ext_dir/.git" ]]; then
            git -C "$ext_dir" pull || {
                print_warning "Git pull failed. Using existing local copy."
            }
        elif [[ -d "$ext_dir" ]]; then
            print_info "Local copy exists but no .git. Re-cloning..."
            rm -rf "$ext_dir"
            git clone --depth 1 "$source" "$ext_dir" || {
                print_error "Failed to clone repository"
                return 1
            }
        else
            print_info "No local copy. Cloning..."
            git clone --depth 1 "$source" "$ext_dir" || {
                print_error "Failed to clone repository"
                return 1
            }
        fi
        desktop_external_load_package "$id" || {
            print_error "Failed to load package after update"
            return 1
        }
    elif [[ "$source" == "local" ]]; then
        if ! desktop_registry_load_package "$id"; then
            if ! desktop_package_load "$id"; then
                print_error "Bundled desktop not found: $id"
                return 1
            fi
        fi
    else
        desktop_package_validate_and_load_external "$source" || {
            print_error "Failed to load package from: $source"
            return 1
        }
    fi

    print_info "Dang tao plan cap nhat..."
    plan_reset
    desktop_generate_plan

    if [[ "$(plan_size)" -eq 0 ]]; then
        print_info "Khong co gi de cap nhat."
        return 0
    fi

    plan_render
    echo

    if plan_detect_conflicts; then
        :
    else
        print_warning "Some destinations already have files. Update will overwrite them."
        echo
    fi

    local answer
    read -rp "Update '$id'? [y/N]: " answer
    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            desktop_pipeline_execute || {
                print_error "Update failed"
                return 1
            }
            profile_registry_register \
                "$ID" \
                "$NAME" \
                "$VERSION" \
                "$source" \
                "${DESKTOP_PREVIOUS_SNAPSHOT:-}"
            profile_registry_activate "$ID"
            print_success "Update complete: $NAME"
            ;;
        *)
            print_warning "Update cancelled."
            ;;
    esac
}
