#!/usr/bin/env bash

theme_dispatch() {

    case "${1:-}" in

        list|"")

            log_info "Running theme manager"

            run_themes

            ;;

        install)

            shift

            log_info "Running theme installer"

            run_theme_install "$@"

            ;;

        uninstall)

            shift

            log_info "Running theme uninstaller"

            run_theme_uninstall "$@"

            ;;

        *)

            print_error "Usage: hcc theme <list|install|uninstall> [name]"

            ;;

    esac

}
