session_dispatch() {
    local action="${1:-}"

    case "$action" in
        setup-login)
            if [[ "$(id -u)" -ne 0 ]]; then
                if command -v sudo &>/dev/null; then
                    exec sudo HCC_REAL_USER="$USER" HCC_REAL_HOME="$HOME" "$0" session setup-login "$@"
                fi
                print_error "Can session setup-login can sudo"
                echo "  sudo hcc session setup-login"
                return 1
            fi
            dm_install_entry "HCC" "/usr/lib/hcc/session-launcher"
            print_success "Da tao login entry cho HCC"
            echo "Logout → chon 'HCC' tren man hinh login"
            ;;
        *)
            echo "Usage: hcc session setup-login"
            echo
            echo "Commands:"
            echo "  setup-login  Tao login entries cho Display Manager (can sudo)"
            ;;
    esac
}
