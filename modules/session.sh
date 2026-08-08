session_dispatch() {
    local action="${1:-}"
    local name="${2:-}"

    case "$action" in
        setup-login)
            if [[ -z "$name" ]]; then
                local default_name="${SESSION_NAME:-HCC}"
                read -rp "Ten session hien thi tren man hinh login [${default_name}]: " name
                name="${name:-$default_name}"
            fi
            if [[ "$(id -u)" -ne 0 ]]; then
                if command -v sudo &>/dev/null; then
                    exec sudo HCC_REAL_USER="$USER" HCC_REAL_HOME="$HOME" "$0" session setup-login "$name"
                fi
                print_error "Can session setup-login can sudo"
                echo "  sudo hcc session setup-login <ten-session>"
                return 1
            fi
            dm_install_entry "$name" "/usr/lib/hcc/session-launcher"
            print_success "Da tao login entry: $name"
            echo "Logout → chon '$name' tren man hinh login"
            ;;
        *)
            echo "Usage: hcc session setup-login [ten-session]"
            echo
            echo "Commands:"
            echo "  setup-login [ten]  Tao login entries cho Display Manager (can sudo)"
            ;;
    esac
}
