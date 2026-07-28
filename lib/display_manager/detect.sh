HCC_DM=""

dm_detect() {
    if [[ -f /etc/systemd/system/display-manager.service ]]; then
        local link
        link="$(readlink /etc/systemd/system/display-manager.service 2>/dev/null || true)"
        if [[ -n "$link" ]]; then
            HCC_DM="$(basename "$link" .service)"
            return 0
        fi
    fi

    for dm in sddm gdm lightdm greetd; do
        if command -v "$dm" &>/dev/null; then
            HCC_DM="$dm"
            return 0
        fi
        if systemctl is-active --quiet "$dm" 2>/dev/null; then
            HCC_DM="$dm"
            return 0
        fi
    done

    return 1
}

dm_wayland_sessions_dir() {
    echo "/usr/share/wayland-sessions"
}

dm_xsessions_dir() {
    echo "/usr/share/xsessions"
}

dm_install_entry() {
    local desktop_name="${1:-HCC}"
    local exec_path="${2:-/usr/lib/hcc/session-launcher}"
    local dm

    dm="${HCC_DM:-$(dm_detect && echo "$HCC_DM")}"
    local dir

    case "$dm" in
        sddm|gdm|"")
            dir="$(dm_wayland_sessions_dir)"
            ;;
        lightdm)
            dir="$(dm_wayland_sessions_dir)"
            if [[ ! -d "$dir" ]]; then
                dir="$(dm_xsessions_dir)"
            fi
            ;;
        greetd)
            dir="$(dm_wayland_sessions_dir)"
            print_info "greetd detected. You may need to configure /etc/greetd/config.toml manually."
            ;;
    esac

    if [[ ! -d "$dir" ]]; then
        print_warning "DM sessions directory not found: $dir"
        return 1
    fi

    local desktop_file="$dir/${desktop_name,,}.desktop"
    if [[ ! -f "$desktop_file" ]]; then
        cat > "$desktop_file" << EOF
[Desktop Entry]
Name=$desktop_name
Comment=Hyprland Control Center
Exec=$exec_path
Type=Application
DesktopNames=Hyprland
EOF
        print_success "Created: $desktop_file"
    else
        print_info "Already exists: $desktop_file"
    fi
}

dm_remove_entry() {
    local desktop_name="${1:-HCC}"
    local dirs
    dirs="$(dm_wayland_sessions_dir) $(dm_xsessions_dir)"
    local dir file

    for dir in $dirs; do
        file="$dir/${desktop_name,,}.desktop"
        if [[ -f "$file" ]]; then
            rm -f "$file"
            print_success "Removed: $file"
        fi
    done
}
