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

    dm_ensure_launcher "$exec_path"

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
    local content="[Desktop Entry]
Name=$desktop_name
Comment=Hyprland Control Center
Exec=$exec_path
Type=Application
DesktopNames=Hyprland
"
    if [[ -f "$desktop_file" ]]; then
        print_info "Already exists: $desktop_file"
        return 0
    fi

    if [[ -w "$dir" ]]; then
        printf '%s' "$content" > "$desktop_file"
    else
        printf '%s' "$content" | sudo tee "$desktop_file" >/dev/null
    fi
    if [[ -f "$desktop_file" ]]; then
        print_success "Created: $desktop_file"
    else
        print_warning "Khong the tao: $desktop_file (can sudo)"
    fi
}

dm_remove_entry() {
    local desktop_name="${1:-HCC}"
    local dirs
    dirs="$(dm_wayland_sessions_dir) $(dm_xsessions_dir)"
    local dir file removed=0

    for dir in $dirs; do
        file="$dir/${desktop_name,,}.desktop"
        if [[ -f "$file" ]]; then
            if [[ -w "$dir" ]]; then
                rm -f "$file"
            else
                sudo rm -f "$file"
            fi
            print_success "Removed: $file"
            removed=1
        fi
    done
    [[ "$removed" -eq 1 ]] || print_warning "Khong tim thay login entry: ${desktop_name,,}.desktop"
}

dm_ensure_launcher() {
    local exec_path="${1:-/usr/lib/hcc/session-launcher}"
    local src="$PROJECT_ROOT/lib/launchers/session-launcher.sh"

    if [[ -f "$exec_path" && -x "$exec_path" ]]; then
        return 0
    fi

    if [[ ! -f "$src" ]]; then
        print_warning "Khong tim thay source launcher: $src"
        return 1
    fi

    local dir
    dir="$(dirname "$exec_path")"
    if [[ -w "$dir" ]]; then
        cp "$src" "$exec_path" 2>/dev/null && chmod +x "$exec_path"
    else
        sudo mkdir -p "$dir" 2>/dev/null
        sudo cp "$src" "$exec_path" 2>/dev/null
        sudo chmod +x "$exec_path" 2>/dev/null
    fi

    if [[ -x "$exec_path" ]]; then
        print_success "Da cai session launcher: $exec_path"
        return 0
    fi
    print_warning "Khong cai duoc session launcher: $exec_path (can sudo)"
    return 1
}
