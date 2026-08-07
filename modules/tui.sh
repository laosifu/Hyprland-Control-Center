tui_dispatch() {
    LANG_MODE="vi"
    case "${HCC_LANG:-${LANG:-}}" in
        en*|EN*) LANG_MODE="en" ;;
    esac
    if has_command fzf; then
        tui_menu_fzf
    elif has_command whiptail; then
        tui_menu_whiptail
    elif has_command dialog; then
        tui_menu_dialog
    else
        tui_menu_select
    fi
}

tui_header() {
    clear 2>/dev/null || true
    if [[ "$LANG_MODE" == "en" ]]; then
        echo "╔══════════════════════════════════════════╗"
        echo "║     Hyprland Control Center v$VERSION       ║"
        echo "║     Interactive TUI                       ║"
        echo "╚══════════════════════════════════════════╝"
    else
        echo "╔══════════════════════════════════════════╗"
        echo "║     Hyprland Control Center v$VERSION       ║"
        echo "║     Giao dien tuong tac - Interactive     ║"
        echo "╚══════════════════════════════════════════╝"
    fi
    echo
}

tui_menu_fzf() {
    local choice
    while true; do
    choice=$(printf "%s\n" \
        "🖥️  Cai dat Desktop (Install Desktop)" \
        "📋  Quan ly Profile (Profile Management)" \
        "🔧  Kiem tra he thong (Doctor & System)" \
        "💾  Backup & Restore" \
        "🎨  Theme & Plugin" \
        "🌐  Tim kiem cong dong (Community Search)" \
        "🤖  AI Integration" \
        "📦  Tu cap nhat (Self-Update)" \
        "🗑️  Go bo HCC (Uninstall HCC)" \
        "📖  Tro giup (Help)" \
        "❌  Thoat (Exit)" | fzf --prompt="HCC > " \
            --header="Chon chuc nang / Select a function" \
            --height=60% \
            --no-info)

        [[ -z "$choice" ]] && break
        [[ "$choice" == *"Thoat"* || "$choice" == *"Exit"* ]] && break
        tui_handle_choice "${choice%% *}"
    done
}

tui_menu_whiptail() {
    local choice
    while true; do
    choice=$(whiptail --title "Hyprland Control Center v$VERSION" \
        --menu "Chon chuc nang / Select a function:" \
        20 65 11 \
        "1" "🖥️  Cai dat Desktop (Install Desktop)" \
        "2" "📋  Quan ly Profile (Profile Management)" \
        "3" "🔧  Kiem tra he thong (Doctor & System)" \
        "4" "💾  Backup & Restore" \
        "5" "🎨  Theme & Plugin" \
        "6" "🌐  Tim kiem cong dong (Community Search)" \
        "7" "🤖  AI Integration" \
        "8" "📦  Tu cap nhat (Self-Update)" \
        "9" "🗑️  Go bo HCC (Uninstall)" \
        "10" "📖  Tro giup (Help)" \
        "11" "❌  Thoat (Exit)" \
            3>&1 1>&2 2>&3)

        [[ -z "$choice" || "$choice" == "11" ]] && break
        case "$choice" in
            1) tui_menu_desktop ;;
            2) tui_menu_profile ;;
            3) tui_menu_system ;;
            4) tui_menu_backup ;;
            5) tui_menu_theme ;;
            6) tui_menu_search ;;
            7) tui_menu_ai ;;
            8) self_update_dispatch ;;
            9) run_uninstall ; read -rp "Enter de tiep tuc..." ;;
            10) show_help | less ;;
        esac
    done
}

tui_menu_dialog() {
    local choice
    while true; do
        choice=$(dialog --stdout --title "Hyprland Control Center v$VERSION" \
            --menu "Chon chuc nang / Select a function:" \
            20 65 11 \
            1 "🖥️  Cai dat Desktop (Install Desktop)" \
            2 "📋  Quan ly Profile (Profile Management)" \
            3 "🔧  Kiem tra he thong (Doctor & System)" \
            4 "💾  Backup & Restore" \
            5 "🎨  Theme & Plugin" \
            6 "🌐  Tim kiem cong dong (Community Search)" \
            7 "🤖  AI Integration" \
            8 "📦  Tu cap nhat (Self-Update)" \
            9 "🗑️  Go bo HCC (Uninstall)" \
            10 "📖  Tro giup (Help)" \
            11 "❌  Thoat (Exit)")

        [[ -z "$choice" || "$choice" == "11" ]] && break
        case "$choice" in
            1) tui_menu_desktop ;;
            2) tui_menu_profile ;;
            3) tui_menu_system ;;
            4) tui_menu_backup ;;
            5) tui_menu_theme ;;
            6) tui_menu_search ;;
            7) tui_menu_ai ;;
            8) self_update_dispatch ;;
            9) run_uninstall && read -rp "Enter de tiep tuc..." ;;
            10) show_help | less ;;
        esac
    done
}

tui_menu_select() {
    while true; do
        tui_header
        echo "1)  🖥️  Cai dat Desktop (Install Desktop)"
        echo "2)  📋  Quan ly Profile (Profile Management)"
        echo "3)  🔧  Kiem tra he thong (Doctor & System)"
        echo "4)  💾  Backup & Restore"
        echo "5)  🎨  Theme & Plugin"
        echo "6)  🌐  Tim kiem cong dong (Community Search)"
        echo "7)  🤖  AI Integration"
        echo "8)  📦  Tu cap nhat (Self-Update)"
        echo "9)  🗑️  Go bo HCC (Uninstall)"
        echo "10) 📖  Tro giup (Help)"
        echo "0)  ❌  Thoat (Exit)"
        echo
        read -rp "Chon [0-10]: " choice
        case "$choice" in
            1) tui_menu_desktop ; read -rp "Enter de tiep tuc..." ;;
            2) tui_menu_profile ; read -rp "Enter de tiep tuc..." ;;
            3) tui_menu_system ; read -rp "Enter de tiep tuc..." ;;
            4) tui_menu_backup ; read -rp "Enter de tiep tuc..." ;;
            5) tui_menu_theme ; read -rp "Enter de tiep tuc..." ;;
            6) tui_menu_search ; read -rp "Enter de tiep tuc..." ;;
            7) tui_menu_ai ; read -rp "Enter de tiep tuc..." ;;
            8) self_update_dispatch ; read -rp "Enter de tiep tuc..." ;;
            9) run_uninstall ; read -rp "Enter de tiep tuc..." ;;
            10) show_help | less ;;
            0) break ;;
        esac
    done
}

tui_handle_choice() {
    local prefix="$1"
    case "$prefix" in
        🖥️|1) tui_menu_desktop ;;
        📋|2) tui_menu_profile ;;
        🔧|3) tui_menu_system ;;
        💾|4) tui_menu_backup ;;
        🎨|5) tui_menu_theme ;;
        🌐|6) tui_menu_search ;;
        🤖|7) tui_menu_ai ;;
        📦|8) self_update_dispatch ; read -rp "Enter de tiep tuc..." ;;
        🗑️|9) run_uninstall ; read -rp "Enter de tiep tuc..." ;;
        📖|10) show_help | less ;;
        ❌|11) return 9 ;;
    esac
}

# --- Desktop submenu ---
tui_menu_desktop() {
    local choice
    if has_command fzf; then
        choice=$(printf "%s\n" \
            "Cai dat tu registry (Install from registry)" \
            "Cai dat tu URL (Install from URL)" \
            "Xem danh sach (List desktops)" \
            "Tim kiem cong dong (Search community)" \
            "Go cai dat (Uninstall)" \
            "Cap nhat (Update)" \
            "Tao profile moi (Init wizard)" \
            "Xuat profile (Export)" \
            "Gui len cong dong (Submit)" \
            "← Quay lai (Back)" | fzf --prompt="Desktop > " --height=40% --no-info)
        [[ -z "$choice" ]] && return
        [[ "$choice" == "← Quay lai (Back)" ]] && return
        tui_desktop_action "$choice"
    else
        while true; do
            choice=$(whiptail --title "Desktop Management" --menu "Chon:" 18 60 9 \
                "1" "Install from registry" \
                "2" "Install from URL" \
                "3" "List desktops" \
                "4" "Search community" \
                "5" "Uninstall" \
                "6" "Update" \
                "7" "Init wizard" \
                "8" "Export" \
                "9" "Submit" \
                "0" "← Back" 3>&1 1>&2 2>&3)
            [[ -z "$choice" || "$choice" == "0" ]] && break
            case "$choice" in
                1) tui_select_and_install ;;
                2) tui_install_url ;;
                3) run_desktop_list ; whiptail --msgbox "Danh sach desktop da hien thi o tren" 8 40 ;;
                4) tui_search ;;
                5) tui_select_and_uninstall ;;
                6) tui_select_and_update ;;
                7) tui_init_wizard ;;
                8) tui_select_and_export ;;
                9) tui_select_and_submit ;;
            esac
        done
    fi
}

tui_desktop_action() {
    local act="$1"
    case "$act" in
        *registry*) tui_select_and_install ;;
        *URL*) tui_install_url ;;
        *List*|*danh*)
            run_desktop_list
            read -rp "Enter de tiep tuc..."
            tui_menu_desktop
            ;;
        *Search*|*tim*)
            tui_search
            tui_menu_desktop
            ;;
        *Uninstall*|*Go*)
            tui_select_and_uninstall
            tui_menu_desktop
            ;;
        *Update*|*cap*)
            tui_select_and_update
            tui_menu_desktop
            ;;
        *Init*|*Tao*)
            tui_init_wizard
            tui_menu_desktop
            ;;
        *Export*|*Xuat*)
            tui_select_and_export
            tui_menu_desktop
            ;;
        *Submit*|*Gui*)
            tui_select_and_submit
            tui_menu_desktop
            ;;
    esac
}

tui_select_and_install() {
    local desktops ids id
    mapfile -t ids < <(desktop_registry_list 2>/dev/null)
    if [[ ${#ids[@]} -eq 0 ]]; then
        print_warning "Khong co desktop nao trong registry"
        return
    fi
    id=$(printf "%s\n" "${ids[@]}" | fzf --prompt="Chon desktop > " --height=40% --no-info)
    [[ -z "$id" ]] && return
    read -rp "Cai dat '$id'? [y/N] " confirm
    [[ "$confirm" =~ ^[yY]$ ]] && run_desktop_install "$id"
}

tui_install_url() {
    read -rp "Nhap GitHub URL: " url
    [[ -z "$url" ]] && return
    run_desktop_install "$url"
}

tui_select_and_uninstall() {
    local profiles
    profiles=$(hcc profile list 2>/dev/null | grep -oP '^\s*\S+' | head -5 || true)
    if [[ -z "$profiles" ]]; then
        print_warning "Chua co profile nao duoc cai"
        return
    fi
    local id
    id=$(echo "$profiles" | fzf --prompt="Chon profile de go > " --height=30% --no-info)
    [[ -z "$id" ]] && return
    read -rp "Go cai dat '$id'? [y/N] " confirm
    [[ "$confirm" =~ ^[yY]$ ]] && run_desktop_uninstall "$id"
}

tui_select_and_update() {
    local profiles
    profiles=$(hcc profile list 2>/dev/null | grep -oP '^\s*\S+' | head -5 || true)
    if [[ -z "$profiles" ]]; then
        print_warning "Chua co profile nao duoc cai"
        return
    fi
    local id
    id=$(echo "$profiles" | fzf --prompt="Chon profile de cap nhat > " --height=30% --no-info)
    [[ -z "$id" ]] && return
    read -rp "Cap nhat '$id'? [y/N] " confirm
    [[ "$confirm" =~ ^[yY]$ ]] && run_desktop_update "$id"
}

tui_init_wizard() {
    read -rp "Thu muc tao profile (Enter de dung thu muc hien tai): " dir
    run_desktop_init "$dir"
}

tui_select_and_export() {
    local profiles
    profiles=$(hcc profile list 2>/dev/null | grep -oP '^\s*\S+' | head -5 || true)
    if [[ -z "$profiles" ]]; then
        print_warning "Chua co profile nao duoc cai"
        return
    fi
    local id
    id=$(echo "$profiles" | fzf --prompt="Chon profile de xuat > " --height=30% --no-info)
    [[ -z "$id" ]] && return
    read -rp "Thu muc xuat (Enter: ./$id): " out
    run_desktop_export "$id" "${out:-.}"
}

tui_select_and_submit() {
    local profiles
    profiles=$(hcc profile list 2>/dev/null | grep -oP '^\s*\S+' | head -5 || true)
    if [[ -z "$profiles" ]]; then
        print_warning "Chua co profile nao duoc cai"
        return
    fi
    local id
    id=$(echo "$profiles" | fzf --prompt="Chon profile de submit > " --height=30% --no-info)
    [[ -z "$id" ]] && return
    run_desktop_submit "$id"
}

tui_search() {
    read -rp "Nhap tu khoa tim kiem: " keyword
    [[ -z "$keyword" ]] && return
    desktop_registry_community_search "$keyword"
}

# --- Profile submenu ---
tui_menu_profile() {
    while true; do
        if has_command fzf; then
            local choice
            choice=$(printf "%s\n" \
                "Danh sach profile (List)" \
                "Trang thai (Status)" \
                "Chuyen doi (Switch)" \
                "← Quay lai (Back)" | fzf --prompt="Profile > " --height=30% --no-info)
            [[ -z "$choice" || "$choice" == *"Back"* ]] && break
            case "$choice" in
                *List*|*danh*) run_profiles ;;
                *Status*|*Trang*) run_profile_status ;;
                *Switch*|*Chuyen*) tui_profile_switch ;;
            esac
        else
            local choice
            choice=$(whiptail --title "Profile Management" --menu "Chon:" 12 50 4 \
                "1" "Danh sach (List)" \
                "2" "Trang thai (Status)" \
                "3" "Chuyen doi (Switch)" \
                "0" "← Back" 3>&1 1>&2 2>&3)
            [[ -z "$choice" || "$choice" == "0" ]] && break
            case "$choice" in
                1) run_profiles ;;
                2) run_profile_status ;;
                3) tui_profile_switch ;;
            esac
        fi
        read -rp "Enter de tiep tuc..."
    done
}

tui_profile_switch() {
    local profiles id
    profiles=$(hcc profile list 2>/dev/null | grep -oP '^\s*\S+' | head -5 || true)
    [[ -z "$profiles" ]] && { print_warning "Chua co profile nao"; return; }
    id=$(echo "$profiles" | fzf --prompt="Chuyen sang > " --height=30% --no-info)
    [[ -z "$id" ]] && return
    profile_dispatch switch "$id"
}

# --- System submenu ---
tui_menu_system() {
    while true; do
        if has_command fzf; then
            local choice
            choice=$(printf "%s\n" \
                "Doctor (Kiem tra he thong)" \
                "Inventory (Thong tin chi tiet)" \
                "Cleanup (Don dep cache)" \
                "Inspect (Kiem tra repo)" \
                "Session Setup (Cau hinh login)" \
                "← Quay lai (Back)" | fzf --prompt="System > " --height=40% --no-info)
            [[ -z "$choice" || "$choice" == *"Back"* ]] && break
            case "$choice" in
                *Doctor*) run_doctor ; read -rp "Enter de tiep tuc..." ;;
                *Inventory*) inventory_dispatch ; read -rp "Enter de tiep tuc..." ;;
                *Cleanup*) cleanup_dispatch ; read -rp "Enter de tiep tuc..." ;;
                *Inspect*)
                    read -rp "Nhap path hoac URL: " path
                    [[ -n "$path" ]] && inspect_dispatch "$path"
                    read -rp "Enter de tiep tuc..."
                    ;;
                *Session*|*login*)
                    print_warning "Can quyen sudo"
                    sudo hcc session setup-login 2>/dev/null || print_info "Chay: sudo hcc session setup-login"
                    read -rp "Enter de tiep tuc..."
                    ;;
            esac
        else
            local choice
            choice=$(whiptail --title "System Tools" --menu "Chon:" 15 50 6 \
                "1" "Doctor (System check)" \
                "2" "Inventory" \
                "3" "Cleanup" \
                "4" "Inspect" \
                "5" "Session Setup" \
                "0" "← Back" 3>&1 1>&2 2>&3)
            [[ -z "$choice" || "$choice" == "0" ]] && break
            case "$choice" in
                1) run_doctor ;;
                2) inventory_dispatch ;;
                3) cleanup_dispatch ;;
                4) whiptail --inputbox "Path hoac URL:" 8 50 --title "Inspect" 3>&1 1>&2 2>&3 | while IFS= read -r path; do [[ -n "$path" ]] && inspect_dispatch "$path"; done ;;
                5) sudo hcc session setup-login 2>/dev/null || whiptail --msgbox "Chay: sudo hcc session setup-login" 8 50 ;;
            esac
            whiptail --msgbox "Xong!" 8 30
        fi
    done
}

# --- Backup submenu ---
tui_menu_backup() {
    if has_command fzf; then
        local choice
        choice=$(printf "%s\n" \
            "Tao backup (Create backup)" \
            "Khoi phuc (Restore)" \
            "← Quay lai (Back)" | fzf --prompt="Backup > " --height=20% --no-info)
        [[ -z "$choice" || "$choice" == *"Back"* ]] && return
        case "$choice" in
            *Tao*|*Create*) backup_dispatch ; read -rp "Enter de tiep tuc..." ;;
            *Khoi*|*Restore*) restore_dispatch ; read -rp "Enter de tiep tuc..." ;;
        esac
    else
        local choice
        choice=$(whiptail --title "Backup & Restore" --menu "Chon:" 10 40 3 \
            "1" "Create backup" \
            "2" "Restore" \
            "0" "← Back" 3>&1 1>&2 2>&3)
        [[ -z "$choice" || "$choice" == "0" ]] && return
        case "$choice" in
            1) backup_dispatch ;;
            2) restore_dispatch ;;
        esac
        whiptail --msgbox "Xong!" 8 30
    fi
}

# --- Theme submenu ---
tui_menu_theme() {
    if has_command fzf; then
        local choice
        choice=$(printf "%s\n" \
            "Danh sach Theme (List themes)" \
            "Cai Theme (Install theme)" \
            "Go Theme (Uninstall theme)" \
            "Danh sach Plugin (List plugins)" \
            "Cai Plugin (Install plugin)" \
            "Go Plugin (Uninstall plugin)" \
            "← Quay lai (Back)" | fzf --prompt="Theme/Plugin > " --height=40% --no-info)
        [[ -z "$choice" || "$choice" == *"Back"* ]] && return
        case "$choice" in
            *List*themes*|*Danh*sach*Theme*) run_themes ; read -rp "Enter de tiep tuc..." ;;
            *Install*theme*|*Cai*Theme*)
                local name
                read -rp "Ten theme: " name
                [[ -n "$name" ]] && theme_dispatch install "$name"
                read -rp "Enter de tiep tuc..."
                ;;
            *Uninstall*theme*|*Go*Theme*)
                local name
                read -rp "Ten theme: " name
                [[ -n "$name" ]] && theme_dispatch uninstall "$name"
                read -rp "Enter de tiep tuc..."
                ;;
            *List*plugins*|*Danh*sach*Plugin*) plugins_dispatch ; read -rp "Enter de tiep tuc..." ;;
            *Install*plugin*|*Cai*Plugin*)
                local name
                read -rp "Ten plugin: " name
                [[ -n "$name" ]] && plugin_dispatch install "$name"
                read -rp "Enter de tiep tuc..."
                ;;
            *Uninstall*plugin*|*Go*Plugin*)
                local name
                read -rp "Ten plugin: " name
                [[ -n "$name" ]] && plugin_dispatch uninstall "$name"
                read -rp "Enter de tiep tuc..."
                ;;
        esac
    else
        local choice
        choice=$(whiptail --title "Theme & Plugin" --menu "Chon:" 15 45 7 \
            "1" "List themes" \
            "2" "Install theme" \
            "3" "Uninstall theme" \
            "4" "List plugins" \
            "5" "Install plugin" \
            "6" "Uninstall plugin" \
            "0" "← Back" 3>&1 1>&2 2>&3)
        [[ -z "$choice" || "$choice" == "0" ]] && return
        case "$choice" in
            1) run_themes ;;
            2) whiptail --inputbox "Ten theme:" 8 40 3>&1 1>&2 2>&3 | while IFS= read -r name; do [[ -n "$name" ]] && theme_dispatch install "$name"; done ;;
            3) whiptail --inputbox "Ten theme:" 8 40 3>&1 1>&2 2>&3 | while IFS= read -r name; do [[ -n "$name" ]] && theme_dispatch uninstall "$name"; done ;;
            4) plugins_dispatch ;;
            5) whiptail --inputbox "Ten plugin:" 8 40 3>&1 1>&2 2>&3 | while IFS= read -r name; do [[ -n "$name" ]] && plugin_dispatch install "$name"; done ;;
            6) whiptail --inputbox "Ten plugin:" 8 40 3>&1 1>&2 2>&3 | while IFS= read -r name; do [[ -n "$name" ]] && plugin_dispatch uninstall "$name"; done ;;
        esac
        whiptail --msgbox "Xong!" 8 30
    fi
}

# --- Search submenu ---
tui_menu_search() {
    read -rp "Nhap tu khoa tim kiem: " keyword
    [[ -z "$keyword" ]] && return
    desktop_registry_community_search "$keyword"
}

# --- AI submenu ---
tui_menu_ai() {
    if has_command fzf; then
        local choice
        choice=$(printf "%s\n" \
            "Cau hinh API key (Setup)" \
            "Kiem tra trang thai (Status)" \
            "Xoa API key (Remove key)" \
            "← Quay lai (Back)" | fzf --prompt="AI > " --height=30% --no-info)
        [[ -z "$choice" || "$choice" == *"Back"* ]] && return
        case "$choice" in
            *Setup*|*Cau*hinh*) desktop_ai_setup ; read -rp "Enter de tiep tuc..." ;;
            *Status*|*Kiem*tra*)
                if desktop_ai_load_key; then
                    print_success "AI API key đã được cấu hình."
                else
                    print_warning "AI API key chưa được cấu hình."
                fi
                read -rp "Enter de tiep tuc..."
                ;;
            *Remove*|*Xoa*) desktop_ai_remove_key ; read -rp "Enter de tiep tuc..." ;;
        esac
    else
        local choice
        choice=$(whiptail --title "AI Integration" --menu "Chon:" 12 40 4 \
            "1" "Setup API key" \
            "2" "Status" \
            "3" "Remove key" \
            "0" "← Back" 3>&1 1>&2 2>&3)
        [[ -z "$choice" || "$choice" == "0" ]] && return
        case "$choice" in
            1) desktop_ai_setup ;;
            2)
                if desktop_ai_load_key; then
                    whiptail --msgbox "AI API key đã được cấu hình." 8 30
                else
                    whiptail --msgbox "AI API key chưa được cấu hình." 8 30
                fi
                ;;
            3) desktop_ai_remove_key ;;
        esac
        whiptail --msgbox "Xong!" 8 30
    fi
}
