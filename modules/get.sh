run_get() {
    local target="${1:-}"

    if [[ -z "$target" ]]; then
        print_error "Usage: hcc get <profile-name|url>"
        print_info "Examples:"
        echo "  hcc get end-4"
        echo "  hcc get https://github.com/end-4/dots-hyprland"
        echo
        print_info "'get' is a super command that combines:"
        echo "  1. Check HCC is installed (auto-install if needed)"
        echo "  2. Detect your system"
        echo "  3. Install the desktop"
        echo "  4. Set up login screen"
        return 1
    fi

    if ! command -v hcc &>/dev/null; then
        print_warning "HCC is not installed. Installing..."
        local install_script
        install_script="$(curl -sL https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh 2>/dev/null)" || {
            print_error "Failed to download installer"
            return 1
        }
        bash -s <<< "$install_script" || {
            print_error "Failed to install HCC"
            return 1
        }
        print_success "HCC installed successfully"
        echo
        exec hcc get "$@"
    fi

    print_info "Running: hcc desktop install $target"
    echo

    hcc desktop install "$target" || {
        print_error "Installation failed"
        return 1
    }

    local profile_id
    profile_id="$(hcc profile status 2>/dev/null | head -1 || true)"
    if [[ -n "$profile_id" ]]; then
        echo
        print_info "Setting up login screen..."
        sudo hcc session setup-login 2>/dev/null || \
            print_warning "Run later: sudo hcc session setup-login"
    fi

    echo
    print_success "Done! Restart or select HCC from your login screen."
}
