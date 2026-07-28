tui_dispatch() {
    if has_command fzf; then
        tui_fzf
    elif has_command whiptail; then
        tui_whiptail
    elif has_command dialog; then
        tui_dialog
    else
        print_warning "Thieu fzf/whiptail/dialog. Cai bang: sudo pacman -S fzf"
        print_info "Dang dung che do menu don gian (select)..."
        tui_select
    fi
}

tui_fzf() {
    local desktops
    desktops=$(desktop_registry_list 2>/dev/null | grep -v '^$' | sort -u)

    if [[ -z "$desktops" ]]; then
        print_warning "Khong co desktop nao trong registry"
        return 1
    fi

    local selected
    selected=$(echo "$desktops" | fzf --prompt="Chon desktop > " \
        --header="Hyprland Control Center - Chon desktop de cai dat" \
        --preview="hcc inspect {} 2>/dev/null || echo 'Khong the xem truoc'" \
        --preview-window=right:60% \
        --height=40%)

    if [[ -n "$selected" ]]; then
        echo
        print_info "Da chon: $selected"
        read -rp "Cai dat ngay? [y/N] " confirm
        if [[ "$confirm" =~ ^[yY]$ ]]; then
            run_desktop_install "$selected"
        fi
    fi
}

tui_whiptail() {
    local desktops=()
    local desktop_ids=()
    local id

    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        desktop_ids+=("$id")
        local info
        info=$(desktop_package_load "$id" 2>/dev/null && echo "${DESKTOP_PACKAGE_NAME:-$id}" || echo "$id")
        desktops+=("$id" "$info")
    done < <(desktop_registry_list 2>/dev/null)

    if [[ ${#desktop_ids[@]} -eq 0 ]]; then
        print_warning "Khong co desktop nao trong registry"
        return 1
    fi

    local selected
    selected=$(whiptail --title "Hyprland Control Center" \
        --menu "Chon desktop de cai dat:" \
        20 60 10 \
        "${desktops[@]}" \
        3>&1 1>&2 2>&3)

    if [[ -n "$selected" ]]; then
        echo
        print_info "Da chon: $selected"
        read -rp "Cai dat ngay? [y/N] " confirm
        if [[ "$confirm" =~ ^[yY]$ ]]; then
            run_desktop_install "$selected"
        fi
    fi
}

tui_dialog() {
    local desktops=()
    local id

    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        local info
        info=$(desktop_package_load "$id" 2>/dev/null && echo "${DESKTOP_PACKAGE_NAME:-$id}" || echo "$id")
        desktops+=("$id" "$info")
    done < <(desktop_registry_list 2>/dev/null)

    if [[ ${#desktops[@]} -eq 0 ]]; then
        print_warning "Khong co desktop nao trong registry"
        return 1
    fi

    local selected
    selected=$(dialog --stdout --title "Hyprland Control Center" \
        --menu "Chon desktop de cai dat:" \
        20 60 10 "${desktops[@]}")

    if [[ -n "$selected" ]]; then
        echo
        print_info "Da chon: $selected"
        read -rp "Cai dat ngay? [y/N] " confirm
        if [[ "$confirm" =~ ^[yY]$ ]]; then
            run_desktop_install "$selected"
        fi
    fi
}

tui_select() {
    local desktops=()
    local id

    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        desktops+=("$id")
    done < <(desktop_registry_list 2>/dev/null)

    if [[ ${#desktops[@]} -eq 0 ]]; then
        print_warning "Khong co desktop nao trong registry"
        return 1
    fi

    echo "Chon desktop de cai dat:"
    select selected in "${desktops[@]}"; do
        if [[ -n "$selected" ]]; then
            echo
            print_info "Da chon: $selected"
            read -rp "Cai dat ngay? [y/N] " confirm
            if [[ "$confirm" =~ ^[yY]$ ]]; then
                run_desktop_install "$selected"
            fi
            break
        else
            print_warning "Lua chon khong hop le"
        fi
    done
}
