#!/usr/bin/env bash

session_dispatch() {

    case "${1:-list}" in

        list|"")
            run_session_list
            ;;

        switch|select)
            run_session_switch
            ;;

        activate)
            shift
            run_session_activate "$@"
            ;;

        isolate)
            shift
            run_session_capture "$@"
            ;;

        deploy)
            shift
            run_session_restore "$@"
            ;;

        remove)
            shift
            run_session_remove "$@"
            ;;

        setup-login)
            run_session_setup_login
            ;;

        status)
            run_session_status
            ;;

        help|--help)
            session_show_help
            ;;

        *)
            print_error "Usage: hcc session <list|switch|activate|remove|setup-login|status> [id]"
            return 1
            ;;

    esac

}

session_show_help() {

    print_header "HCC Session Manager"

    print_info "Quan ly cac Hyprland sessions (desktop profiles)."
    echo
    print_info "Cach dung:"
    echo "    hcc session                  Xem danh sach session"
    echo "    hcc session list             Xem danh sach session"
    echo "    hcc session switch           Menu tuong tac chon session"
    echo "    hcc session activate <id>    Kich hoat session (deploy symlink)"
    echo "    hcc session isolate <id>     Move config vao session dir + symlink"
    echo "    hcc session deploy <id>      Tao symlink tu HOME den session dir"
    echo "    hcc session remove <id>      Xoa session"
    echo "    hcc session setup-login      Tao login entries cho Display Manager"
    echo "    hcc session status           Xem session dang dung"
    echo
    print_info "Login entries duoc tao tai /usr/share/wayland-sessions/hcc-<id>.desktop"
    print_info "giup ban chon session ngay tren man hinh login (SDDM/GDM)."

}
