session_dispatch() {
    local action="${1:-}"

    case "$action" in
        setup-login)
            if [[ "$(id -u)" -ne 0 ]]; then
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
