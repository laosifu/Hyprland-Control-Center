#!/usr/bin/env bash

run_session_list() {
    local active
    local id
    local count=0

    active="$(session_active)" 2>/dev/null || true

    print_header "HCC Sessions"

    while read -r id
    do
        [[ -z "$id" ]] && continue
        session_load "$id" || continue
        ((count++))
        printf '%2d) %s (%s)' "$count" "${SESSION_NAME:-$id}" "$SESSION_VERSION"
        [[ "$id" == "$active" ]] && printf ' [ACTIVE]'
        printf '\n    Source: %s\n    Installed: %s\n' "$SESSION_SOURCE" "$SESSION_INSTALLED_AT"
    done < <(session_list)

    echo
    if [[ -n "$active" ]]; then
        print_info "Active session: $active"
    else
        print_info "No active session."
    fi
    echo
    print_info "Use: hcc session switch (chon session tuong tac)"
}

run_session_status() {
    local active
    active="$(session_active)" 2>/dev/null || true

    print_header "Session Status"

    if [[ -z "$active" ]]; then
        print_info "No active session."
        return 0
    fi

    session_load "$active" || return 1

    ui_field "Active" "${SESSION_NAME:-$active} ($active)"
    ui_field "Version" "$SESSION_VERSION"
    ui_field "Source" "$SESSION_SOURCE"
    ui_field "Installed" "$SESSION_INSTALLED_AT"

    local hypr_conf
    hypr_conf="$(session_get_hypr_config "$active")" || hypr_conf="(not found)"

    ui_field "Hyprland Config" "$hypr_conf"
}

run_session_activate() {
    local id="$1"

    [[ -z "$id" ]] && {
        print_error "Usage: hcc session activate <id>"
        print_info "Use: hcc session list (xem danh sach)"
        return 1
    }

    session_exists "$id" || {
        print_error "Session not found: $id"
        return 1
    }

    print_header "Activate Session"
    session_switch "$id"
}

run_session_switch() {
    local ids=()
    local names=()
    local active
    local id
    local i
    local choice

    active="$(session_active)" 2>/dev/null || true

    while read -r id
    do
        [[ -z "$id" ]] && continue
        session_load "$id"
        ids+=("$id")
        names+=("${SESSION_NAME:-$id}")
    done < <(session_list)

    [[ ${#ids[@]} -eq 0 ]] && {
        print_error "No sessions found."
        print_info "Install a desktop first: hcc desktop install <name>"
        return 1
    }

    tui_session_menu "${ids[@]}"
}

run_session_capture() {
    local id="$1"

    [[ -z "$id" ]] && {
        print_error "Usage: hcc session capture <id>"
        return 1
    }

    session_exists "$id" || {
        print_error "Session not found: $id"
        return 1
    }

    print_header "Isolate Session"
    session_isolate "$id"
}

run_session_restore() {
    local id="$1"

    [[ -z "$id" ]] && {
        print_error "Usage: hcc session deploy <id>"
        return 1
    }

    session_exists "$id" || {
        print_error "Session not found: $id"
        return 1
    }

    print_header "Deploy Session"
    session_deploy "$id"
}

run_session_remove() {
    local id="$1"

    [[ -z "$id" ]] && {
        print_error "Usage: hcc session remove <id>"
        return 1
    }

    session_exists "$id" || {
        print_error "Session not found: $id"
        return 1
    }

    session_load "$id"

    print_header "Remove Session"
    ui_field "Session" "${SESSION_NAME:-$id} ($id)"

    echo
    print_warning "This will remove session data from HCC."
    print_info "Use 'hcc desktop uninstall $id' to also remove installed files."

    local answer
    read -rp "Remove session '$id'? [y/N]: " answer
    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            session_remove "$id"
            print_success "Session removed: $id"
            ;;
        *)
            print_warning "Removal cancelled."
            ;;
    esac
}

run_session_setup_login() {
    print_header "Setup Login Entries"

    if [[ ! -w "/usr/share/wayland-sessions" ]]; then
        print_warning "Need root privileges to create login entries."
        print_info "Run: sudo hcc session setup-login"
        return 1
    fi

    local count=0
    local id

    for id in $(session_list)
    do
        session_load "$id" || continue
        local hypr_config
        hypr_config="$(session_get_hypr_config "$id")" || continue

        local desktop_file="/usr/share/wayland-sessions/hcc-$id.desktop"
        cat > "$desktop_file" << EOF
[Desktop Entry]
Name=HCC - ${SESSION_NAME:-$id}
Comment=Hyprland with ${SESSION_NAME:-$id} session configuration
Exec=/usr/lib/hcc/session-launcher $id
Type=Application
DesktopNames=Hyprland
EOF
        ((count++))
        print_success "Created: $desktop_file"
    done

    [[ "$count" -eq 0 ]] && print_info "No sessions with Hyprland config found."
    print_success "Created $count login entr(ies)."

    echo
    print_info "Log out and choose an HCC session from the login screen."
}

tui_session_menu() {
    local ids=("$@")
    local active
    local i
    local choice

    active="$(session_active)" 2>/dev/null || true

    while true
    do
        clear 2>/dev/null || true
        print_header "HCC Session Manager"

        echo "  Installed sessions:"
        echo

        for i in "${!ids[@]}"
        do
            session_load "${ids[$i]}" 2>/dev/null || continue
            local marker="  "
            [[ "${ids[$i]}" == "$active" ]] && marker=" >"
            printf "  %2d) %s %s (%s)\n" \
                $((i + 1)) \
                "$marker" \
                "${SESSION_NAME:-${ids[$i]}}" \
                "$SESSION_VERSION"
        done

        echo
        printf "  %2s) %s\n" "n" "Native Linux (no HCC, restore $HOME)"
        printf "  %2s) %s\n" "c" "Capture current config to active session"
        printf "  %2s) %s\n" "l" "List available desktops in registry"
        printf "  %2s) %s\n" "q" "Quit"
        echo

        read -rp "  Select session (number): " choice

        [[ "$choice" == "q" ]] && { echo; print_info "Bye."; break; }

        if [[ "$choice" == "n" ]]; then
            echo
            print_warning "Restore native Linux (no HCC)?"
            echo "  This will remove ALL HCC session symlinks and restore default Hyprland."
            echo
            read -rp "Restore? [y/N]: " ans
            case "$ans" in
                [Yy]|[Yy][Ee][Ss])
                    session_undeploy
                    rm -f "$(session_active_file)"
                    print_success "Restored native Linux. Log out and select your default session."
                    read -rp "Press Enter to continue..."
                    ;;
            esac
            continue
        fi

        if [[ "$choice" == "c" ]]; then
            if [[ -n "$active" ]]; then
                echo
                print_info "Capturing current config to session: $active"
                session_isolate "$active"
                read -rp "Press Enter to continue..."
            else
                print_info "No active session to capture."
                read -rp "Press Enter to continue..."
            fi
            continue
        fi

        if [[ "$choice" == "l" ]]; then
            echo
            print_info "Available desktops in registry:"
            desktop_registry_list 2>/dev/null | head -20 || print_info "(run 'hcc desktop list')"
            echo
            print_info "Install: hcc desktop install <name>"
            read -rp "Press Enter to continue..."
            continue
        fi

        [[ "$choice" =~ ^[0-9]+$ ]] || continue

        i=$((choice - 1))
        [[ $i -ge 0 && $i -lt ${#ids[@]} ]] || continue

        local target_id="${ids[$i]}"
        [[ "$target_id" == "$active" ]] && {
            print_info "Already on session: $target_id"
            read -rp "Press Enter to continue..."
            continue
        }

        echo
        session_load "$target_id"
        print_warning "Switch to: ${SESSION_NAME:-$target_id}?"
        echo "  This will deploy config files from this session."
        echo

        read -rp "Switch now? [y/N]: " ans
        case "$ans" in
            [Yy]|[Yy][Ee][Ss])
                session_switch "$target_id"
                echo
                print_warning "Reboot or log out and pick 'HCC' at the login screen."
                read -rp "Press Enter to continue..."
                ;;
        esac
    done
}
