run_uninstall() {
    echo
    print_header "HCC Uninstall"
    echo
    print_warning "Thao tac nay se xoa HCC khoi he thong cua ban."
    echo

    local dry_run=false
    [[ "${1:-}" == "--dry-run" ]] && dry_run=true

    echo "Cac thanh phan se bi xoa:"
    echo

    local items=()
    [[ -f "/usr/share/wayland-sessions/hcc.desktop" ]] && items+=("  /usr/share/wayland-sessions/hcc.desktop (login entry)")
    [[ -f "/usr/lib/hcc/session-launcher" ]] && items+=("  /usr/lib/hcc/session-launcher")
    [[ -L "$HOME/.local/bin/hcc" || -f "$HOME/.local/bin/hcc" ]] && items+=("  $HOME/.local/bin/hcc (symlink)")
    [[ -d "$HOME/.config/hcc" ]] && items+=("  $HOME/.config/hcc/ (config: ai.conf, session-active, profiles)")
    [[ -d "$HOME/.local/share/hcc" ]] && items+=("  $HOME/.local/share/hcc/ (data: logs, desktops, manifests)")
    [[ -f "/usr/share/bash-completion/completions/hcc" ]] && items+=("  /usr/share/bash-completion/completions/hcc (bash completions)")
    [[ -f "$HOME/.config/fish/completions/hcc.fish" ]] && items+=("  $HOME/.config/fish/completions/hcc.fish (fish completions)")

    if [[ ${#items[@]} -eq 0 ]]; then
        print_info "Khong tim thay thanh phan nao cua HCC tren he thong."
        echo "  HCC co the da duoc xoa hoac chua duoc cai dat."
        echo
        print_info "De xoa AUR package (neu co):"
        echo "  yay -R hcc-bin"
        echo "  yay -R hcc-git"
        return 0
    fi

    for item in "${items[@]}"; do
        echo "$item"
    done

    echo
    print_warning "Logout entry 'HCC' se bi xoa khoi man hinh login."
    echo

    if [[ "$dry_run" == true ]]; then
        print_info "Day la dry-run. Khong co gi bi xoa."
        return 0
    fi

    local confirm
    read -rp "Xoa HCC? (go 'YES' de xac nhan): " confirm
    [[ "$confirm" != "YES" ]] && { print_info "Da huy."; return 0; }

    echo
    print_info "Dang xoa HCC..."

    # 1. Remove login entry
    if command -v dm_remove_entry &>/dev/null; then
        dm_remove_entry "HCC" "/usr/lib/hcc/session-launcher" 2>/dev/null || true
    fi
    sudo rm -f /usr/share/wayland-sessions/hcc.desktop 2>/dev/null || true
    print_info "  Da xoa login entry"

    # 2. Remove session launcher
    sudo rm -f /usr/lib/hcc/session-launcher 2>/dev/null || true
    sudo rmdir /usr/lib/hcc 2>/dev/null || true
    print_info "  Da xoa session launcher"

    # 3. Remove symlink
    rm -f "$HOME/.local/bin/hcc" 2>/dev/null || true
    print_info "  Da xoa symlink"

    # 4. Remove shell completions
    sudo rm -f /usr/share/bash-completion/completions/hcc 2>/dev/null || true
    rm -f "$HOME/.config/fish/completions/hcc.fish" 2>/dev/null || true
    print_info "  Da xoa shell completions"

    # 5. Remove PATH addition from shell config
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish"; do
        [[ -f "$rc" ]] || continue
        if grep -q '\.local/bin.*PATH' "$rc" 2>/dev/null; then
            local backup="${rc}.bak"
            cp "$rc" "$backup" 2>/dev/null || true
            grep -v '\.local/bin.*PATH' "$rc" > "${rc}.tmp" 2>/dev/null || true
            mv "${rc}.tmp" "$rc" 2>/dev/null || true
            print_info "  Da xoa PATH tu $rc (backup: $backup)"
        fi
    done

    # 6. Remove config files
    rm -rf "$HOME/.config/hcc" 2>/dev/null || true
    print_info "  Da xoa config files"

    # 7. Ask about data directory
    if [[ -d "$HOME/.local/share/hcc" ]]; then
        local keep_data
        read -rp "Giu lai profiles da cai? (du lieu tai ~/.local/share/hcc) [Y/n]: " keep_data
        if [[ "$keep_data" =~ ^[nN] ]]; then
            rm -rf "$HOME/.local/share/hcc" 2>/dev/null || true
            print_info "  Da xoa data directory"
        else
            print_info "  Giu lai: $HOME/.local/share/hcc"
        fi
    fi

    echo
    print_success "HCC da duoc xoa khoi he thong."
    echo
    print_info "De xoa AUR package (neu duoc cai tu AUR):"
    echo "  yay -R hcc-bin   # hoac yay -R hcc-git"
    echo
    print_info "Sau khi xoa AUR package, dong mo terminal de hoan tat."
}
