#!/usr/bin/env bash

run_profiles() {

    local active
    local profile
    local count=0

    active="$(profile_registry_active)"

    print_header "Desktop Profiles"

    while read -r profile
    do
        [[ -z "$profile" ]] && continue

        # profile.conf is validated by profile_registry_list.
        profile_registry_load "$(basename "$(dirname "$profile")")" || continue
        ((++count))

        printf '%2d) %s (%s)' "$count" "$PROFILE_NAME" "$PROFILE_VERSION"
        [[ "$PROFILE_ID" == "$active" ]] && printf ' [active]'
        printf '\n    Source: %s\n    Installed: %s\n' "$PROFILE_SOURCE" "$PROFILE_INSTALLED_AT"
    done < <(profile_registry_list)

    [[ "$count" -gt 0 ]] || print_info "No desktop profiles installed."

}

run_profile_status() {

    local active

    active="$(profile_registry_active)"
    [[ -n "$active" ]] || {
        print_info "No active desktop profile."
        return 0
    }

    profile_registry_load "$active" || return 1
    print_info "Active profile: $PROFILE_NAME ($PROFILE_VERSION)"

}

run_profile_switch() {
    local id="${1:-}"
    local active

    if [[ -z "$id" ]]; then
        print_error "Usage: hcc profile switch <id>"
        print_info "Use: hcc profile list (xem danh sach da cai)"
        return 1
    fi

    if ! profile_registry_exists "$id"; then
        print_error "Profile not found: $id"
        return 1
    fi

    active="$(profile_registry_active)"
    if [[ "$active" == "$id" ]]; then
        print_info "Profile '$id' is already active."
        return 0
    fi

    profile_registry_load "$active" 2>/dev/null || true

    print_header "Switch Profile"
    ui_field "From" "${PROFILE_NAME:-$active} (${PROFILE_VERSION:-})"
    ui_field "To" "$id"
    echo

    local answer
    read -rp "Switch to profile '$id'? [y/N]: " answer
    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            profile_registry_activate "$id"
            print_success "Switched to profile: $id"
            echo
            print_info "Dang xuat de ap dung thay doi."
            print_info "Dang nhap lai de thay desktop moi."
            ;;
        *)
            print_warning "Switch cancelled."
            ;;
    esac
}
