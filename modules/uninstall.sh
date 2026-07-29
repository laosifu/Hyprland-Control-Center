run_uninstall_scan() {
    local -A found
    found[login_entry]=0
    found[session_launcher]=0
    found[symlink]=0
    found[config]=0
    found[data]=0
    found[bash_comp]=0
    found[fish_comp]=0
    found[installed_desktops]=0
    found[installed_themes]=0
    found[installed_plugins]=0
    found[backups]=0
    found[logs]=0
    found[profiles]=0
    found[path_entries]=0
    found[aur_installed]=0

    [[ -f "/usr/share/wayland-sessions/hcc.desktop" ]] && found[login_entry]=1
    [[ -f "/usr/lib/hcc/session-launcher" ]] && found[session_launcher]=1
    [[ -L "$HOME/.local/bin/hcc" || -f "$HOME/.local/bin/hcc" ]] && found[symlink]=1
    [[ -d "$HOME/.config/hcc" ]] && found[config]=1
    [[ -d "$HOME/.local/share/hcc" ]] && found[data]=1
    [[ -f "/usr/share/bash-completion/completions/hcc" ]] && found[bash_comp]=1
    [[ -f "$HOME/.config/fish/completions/hcc.fish" ]] && found[fish_comp]=1
    [[ -d "$HOME/.local/share/hcc/desktops" ]] && found[installed_desktops]=1
    [[ -d "$HOME/.local/share/hcc/profiles" ]] && found[profiles]=1
    [[ -d "$HOME/.local/share/hcc/backups" ]] && found[backups]=1
    [[ -d "$HOME/.local/share/hcc/logs" ]] && found[logs]=1

    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish"; do
        [[ -f "$rc" ]] && grep -q '\.local/bin.*PATH' "$rc" 2>/dev/null && found[path_entries]=1
    done

    if command -v pacman &>/dev/null; then
        pacman -Qi hcc-bin &>/dev/null 2>&1 && found[aur_installed]=1
        pacman -Qi hcc-git &>/dev/null 2>&1 && found[aur_installed]=2
    fi

    declare -p found
}

run_uninstall_show_menu() {
    local -A choices
    local -a order
    local key desc

    choices[login_entry]="1"
    order+=("login_entry|Login entry (/usr/share/wayland-sessions/hcc.desktop)")
    choices[session_launcher]="2"
    order+=("session_launcher|Session launcher (/usr/lib/hcc/session-launcher)")
    choices[symlink]="3"
    order+=("symlink|Symlink ($HOME/.local/bin/hcc)")
    choices[config]="4"
    order+=("config|Config files (~/.config/hcc/: ai.conf, session-active)")
    choices[data]="5"
    order+=("data|Data directory (~/.local/share/hcc/: profiles, backups, logs)")
    choices[installed_desktops]="6"
    order+=("installed_desktops|Installed desktops (trong ~/.local/share/hcc/desktops)")
    choices[profiles]="7"
    order+=("profiles|Profile configurations (trong ~/.local/share/hcc/profiles)")
    choices[backups]="8"
    order+=("backups|Backup snapshots (trong ~/.local/share/hcc/backups)")
    choices[logs]="9"
    order+=("logs|Log files (trong ~/.local/share/hcc/logs)")
    choices[bash_comp]="a"
    order+=("bash_comp|Bash completions (/usr/share/bash-completion/completions/hcc)")
    choices[fish_comp]="b"
    order+=("fish_comp|Fish completions (~/.config/fish/completions/hcc.fish)")
    choices[path_entries]="c"
    order+=("path_entries|PATH entries in shell config (.bashrc, .zshrc, config.fish)")
    choices[aur_installed]="d"
    order+=("aur_installed|AUR package (hcc-bin/hcc-git) - se go bang pacman")

    local -A descriptions
    descriptions[login_entry]="Xoa muc 'HCC' khoi man hinh login DM"
    descriptions[session_launcher]="Xoa /usr/lib/hcc/session-launcher"
    descriptions[symlink]="Xoa symlink $HOME/.local/bin/hcc"
    descriptions[config]="Xoa toan bo cau hinh (AI key, session-active)"
    descriptions[data]="Xoa toan bo du lieu (can than: mat profiles)"
    descriptions[installed_desktops]="Chi xoa desktop da cai tu URL (giu lai profiles)"
    descriptions[profiles]="Xoa cau hinh profile da kich hoat"
    descriptions[backups]="Xoa cac ban snapshot backup"
    descriptions[logs]="Xoa log files"
    descriptions[bash_comp]="Xoa bash completions"
    descriptions[fish_comp]="Xoa fish completions"
    descriptions[path_entries]="Xoa dong 'export PATH=.../.local/bin' khoi shell config"
    descriptions[aur_installed]="Go bo AUR package (yay -R hcc-bin/hcc-git)"

    echo
    print_header "HCC Uninstall - Chon thanh phan can xoa"
    echo
    print_info "Nhap cac ma tuong ung (vd: 1 3 5 hoac 1-5). Enter de bo qua."
    echo

    local idx=1
    local -A map
    for entry in "${order[@]}"; do
        local k="${entry%%|*}"
        local d="${entry#*|}"
        local status=" "
        echo "  $idx) $status $d"
        map[$idx]="$k"
        ((idx++))
    done
    echo

    local raw
    read -rp "Chon [1-$(($idx-1)), cach nhau boi空格 hoac 0=all]: " raw

    [[ -z "$raw" ]] && return 1

    local -a selected
    if [[ "$raw" == "0" ]]; then
        selected=("${order[@]}")
    else
        local tokens
        tokens=($raw)
        for t in "${tokens[@]}"; do
            if [[ "$t" == *-* ]]; then
                local start="${t%-*}"
                local end="${t#*-}"
                for ((i=start; i<=end; i++)); do
                    [[ -n "${map[$i]:-}" ]] && selected+=("${map[$i]}")
                done
            else
                [[ -n "${map[$t]:-}" ]] && selected+=("${map[$t]}")
            fi
        done
    fi

    if [[ ${#selected[@]} -eq 0 ]]; then
        print_warning "Khong co thanh phan nao duoc chon."
        return 1
    fi

    echo
    print_info "Cac thanh phan se bi xoa:"
    for k in "${selected[@]}"; do
        echo "  - ${descriptions[$k]}"
    done
    echo

    local confirm
    read -rp "Xac nhan xoa? (go 'YES' de xoa): " confirm
    [[ "$confirm" != "YES" ]] && { print_info "Da huy."; return 1; }

    for k in "${selected[@]}"; do
        run_uninstall_item "$k"
    done
    return 0
}

run_uninstall_item() {
    local item="$1"
    case "$item" in
        login_entry)
            if command -v dm_remove_entry &>/dev/null; then
                dm_remove_entry "HCC" "/usr/lib/hcc/session-launcher" 2>/dev/null || true
            fi
            sudo rm -f /usr/share/wayland-sessions/hcc.desktop 2>/dev/null || true
            print_success "  Da xoa login entry"
            ;;
        session_launcher)
            sudo rm -f /usr/lib/hcc/session-launcher 2>/dev/null || true
            sudo rmdir /usr/lib/hcc 2>/dev/null || true
            print_success "  Da xoa session launcher"
            ;;
        symlink)
            rm -f "$HOME/.local/bin/hcc" 2>/dev/null || true
            print_success "  Da xoa symlink"
            ;;
        config)
            rm -rf "$HOME/.config/hcc" 2>/dev/null || true
            print_success "  Da xoa config files (~/.config/hcc/)"
            ;;
        data)
            rm -rf "$HOME/.local/share/hcc" 2>/dev/null || true
            print_success "  Da xoa data directory (~/.local/share/hcc/)"
            ;;
        installed_desktops)
            rm -rf "$HOME/.local/share/hcc/desktops" 2>/dev/null || true
            print_success "  Da xoa installed desktops"
            ;;
        profiles)
            rm -rf "$HOME/.local/share/hcc/profiles" 2>/dev/null || true
            print_success "  Da xoa profile configurations"
            ;;
        backups)
            rm -rf "$HOME/.local/share/hcc/backups" 2>/dev/null || true
            print_success "  Da xoa backup snapshots"
            ;;
        logs)
            rm -rf "$HOME/.local/share/hcc/logs" 2>/dev/null || true
            print_success "  Da xoa log files"
            ;;
        bash_comp)
            sudo rm -f /usr/share/bash-completion/completions/hcc 2>/dev/null || true
            print_success "  Da xoa bash completions"
            ;;
        fish_comp)
            rm -f "$HOME/.config/fish/completions/hcc.fish" 2>/dev/null || true
            print_success "  Da xoa fish completions"
            ;;
        path_entries)
            for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish"; do
                [[ -f "$rc" ]] || continue
                if grep -q '\.local/bin.*PATH' "$rc" 2>/dev/null; then
                    local backup="${rc}.bak"
                    cp "$rc" "$backup" 2>/dev/null || true
                    grep -v '\.local/bin.*PATH' "$rc" > "${rc}.tmp" 2>/dev/null || true
                    mv "${rc}.tmp" "$rc" 2>/dev/null || true
                    print_success "  Da xoa PATH tu $rc (backup: $backup)"
                fi
            done
            ;;
        aur_installed)
            if command -v hcc-bin &>/dev/null; then
                print_info "  Dang go AUR package hcc-bin..."
                yay -R hcc-bin 2>/dev/null || sudo pacman -R hcc-bin 2>/dev/null || print_warning "  Tu go: yay -R hcc-bin"
            fi
            if command -v hcc-git &>/dev/null; then
                print_info "  Dang go AUR package hcc-git..."
                yay -R hcc-git 2>/dev/null || sudo pacman -R hcc-git 2>/dev/null || print_warning "  Tu go: yay -R hcc-git"
            fi
            print_success "  Da go AUR package"
            ;;
    esac
}

run_uninstall() {
    local mode="${1:-menu}"

    case "$mode" in
        --dry-run|dry-run)
            run_unittest_scan
            print_info "Dry-run mode - khong co gi bi xoa"
            return 0
            ;;
        --all|all)
            run_uninstall_item login_entry
            run_uninstall_item session_launcher
            run_uninstall_item symlink
            run_uninstall_item bash_comp
            run_uninstall_item fish_comp
            run_uninstall_item path_entries
            run_uninstall_item config
            run_uninstall_item data
            run_uninstall_item aur_installed
            print_success "Da xoa toan bo HCC khoi he thong."
            return 0
            ;;
        menu|*)
            run_uninstall_show_menu
            ;;
    esac

    echo
    if [[ -d "$HOME/.config/hcc" || -d "$HOME/.local/share/hcc" ]]; then
        print_warning "Mot so thanh phan van con ton tai."
        echo "  Chay lai 'hcc uninstall' de chon them."
    else
        print_success "HCC da duoc xoa khoi he thong."
    fi
    echo
    print_info "Dong mo terminal de hoan tat."
    echo
    if command -v pacman &>/dev/null && (pacman -Qi hcc-bin &>/dev/null 2>&1 || pacman -Qi hcc-git &>/dev/null 2>&1); then
        print_info "AUR package van con. De xoa hoan toan:"
        echo "  yay -R hcc-bin   # hoac yay -R hcc-git"
    fi
}
