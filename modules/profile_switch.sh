run_profile_switch() {
    local target_id="$1"
    local active_dir
    local answer

    if [[ -z "$target_id" ]]; then
        print_error "Usage: hcc profile switch <id>"
        return 1
    fi

    if ! profile_registry_exists "$target_id"; then
        print_error "Profile not found: $target_id"
        print_info "Use: hcc profile list (xem danh sach profile)"
        return 1
    fi

    profile_registry_load "$target_id" || return 1

    local target_name="$PROFILE_NAME"
    local target_version="$PROFILE_VERSION"

    print_header "Switch Profile"
    ui_field "Target" "$target_name ($target_id)"
    ui_field "Version" "$target_version"

    local active
    active="$(profile_registry_active)"

    if [[ -n "$active" ]]; then
        profile_registry_load "$active"
        ui_field "Current" "$PROFILE_NAME ($active)"
    fi

    echo

    if [[ "$active" == "$target_id" ]]; then
        print_warning "Already on profile: $target_id"
        return 0
    fi

    print_warning "This will:"
    echo "  1. Backup current profile's deployed config files"
    echo "  2. Restore target profile's config files from snapshot"
    echo "  3. Switch active marker"
    echo

    read -rp "Switch to '$target_id'? [y/N]: " answer
    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            if [[ -n "$active" ]]; then
                print_info "Backing up current profile: $active"
                active_dir="$(profile_registry_directory "$active")"
                backup_create_snapshot
            fi

            print_info "Restoring target profile: $target_id"
            profile_ownership_restore "$target_id" || {
                print_warning "Some files could not be restored."
                print_info "Check snapshot existence: hcc profile list"
            }

            profile_registry_activate "$target_id"
            print_success "Active profile switched to: $target_name"
            ;;
        *)
            print_warning "Switch cancelled."
            ;;
    esac
}
