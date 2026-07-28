run_desktop_submit() {
    local id="${1:-}"
    local profile_file

    if [[ -n "$id" ]]; then
        profile_file="$(desktop_external_package_file "$id" 2>/dev/null)"
        if [[ -z "$profile_file" || ! -f "$profile_file" ]]; then
            profile_file="$(desktop_registry_file "$id" 2>/dev/null)"
        fi
    fi

    if [[ -z "$profile_file" || ! -f "$profile_file" ]]; then
        print_header "Submit to Community Registry"
        echo
        print_info "To submit your desktop to the HCC community registry:"
        echo
        print_info "1. Create a GitHub repo with your desktop profile:"
        echo "   Repo structure:"
        echo "     ├── hcc.manifest"
        echo "     ├── package.toml (or package.conf)"
        echo "     └── payload/"
        echo
        print_info "2. Fork the community registry:"
        echo "   https://github.com/hyprland-control-center/community-registry"
        echo
        print_info "3. Add your entry to registry.txt:"
        echo "   Name|https://github.com/you/your-repo|Short description"
        echo
        print_info "4. Submit a Pull Request"
        echo
        print_info "Or run: hcc desktop init . (to create a profile from current config)"
        echo
        print_info "Then: hcc desktop submit <id> (after installing your profile)"
        return 0
    fi

    profile_registry_load "$id" 2>/dev/null || true

    local name="${PROFILE_NAME:-$NAME}"
    local version="${PROFILE_VERSION:-$VERSION}"
    local source="${PROFILE_SOURCE:-local}"

    print_header "Submit to Community Registry"
    ui_field "Profile" "${name:-$id}"
    ui_field "Version" "${version:-unknown}"
    ui_field "Source" "$source"
    echo

    if [[ "$source" == "local" ]]; then
        print_warning "This profile was installed from the bundled registry."
        print_info "To submit it, first push your changes to GitHub."
        echo
        print_info "Steps:"
        echo "  1. Create a GitHub repo with your profile"
        echo "  2. Run: hcc desktop install https://github.com/you/your-repo"
        echo "  3. Then run: hcc desktop submit $id"
        return 0
    fi

    print_info "To submit this desktop to the community registry:"
    echo
    print_info "1. Fork the registry:"
    echo "   https://github.com/hyprland-control-center/community-registry"
    echo
    print_info "2. Add this line to registry.txt:"
    echo "   ${name:-$id}|$source|${PROFILE_DESCRIPTION:-$DESCRIPTION}"
    echo
    print_info "3. Submit a Pull Request"
    echo
    print_info "Community registry URL:"
    echo "   $HCC_COMMUNITY_REGISTRY_URL"
    echo
    print_info "Format docs: docs/community-registry/CONTRIBUTING.md"
}
