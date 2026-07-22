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
