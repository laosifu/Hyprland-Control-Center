#!/usr/bin/env bash

desktop_dispatch() {

    case "${1:-list}" in

        list|"")

            log_info "Listing available desktops"

            run_desktop_list

            ;;

        install)

            shift

            log_info "Running desktop installer"

            run_desktop_install "$@"

            ;;

        uninstall)

            shift

            log_info "Running desktop uninstaller"

            run_desktop_uninstall "$@"

            ;;

        *)

            print_error "Usage: hcc desktop <list|install|uninstall> [name]"

            ;;

    esac

}