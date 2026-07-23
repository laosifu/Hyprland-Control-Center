# end-4 illogical-impulse post-install hook
# Deploys config files from cloned repo and initializes submodules

end4_deploy_config() {
    local dots_dir="$HOME/.config/end-4-dots"

    if [[ ! -d "$dots_dir" ]]; then
        print_error "end-4 dots repository not found at $dots_dir"
        return 1
    fi

    print_info "Initializing git submodules..."
    git -C "$dots_dir" submodule update --init --recursive 2>/dev/null || \
        print_warning "Submodule initialization incomplete (non-fatal)"

    print_info "Deploying config files..."
    if [[ -d "$dots_dir/dots/.config" ]]; then
        rsync -a --no-o --no-g "$dots_dir/dots/.config/" "$HOME/.config/"
        print_success "Config files deployed to ~/.config"
    fi

    if [[ -d "$dots_dir/dots/.local" ]]; then
        rsync -a --no-o --no-g "$dots_dir/dots/.local/" "$HOME/.local/"
        print_success "Local files deployed to ~/.local"
    fi

    print_info "end-4 dotfiles deployed successfully"
    print_info "Run './setup install' in $dots_dir for full setup"
}

end4_deploy_config
