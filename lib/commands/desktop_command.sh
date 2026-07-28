#!/usr/bin/env bash

desktop_dispatch() {

    case "${1:-list}" in

        list|"")

            log_info "Listing available desktops"

            run_desktop_list

            ;;

        search)

            shift

            log_info "Searching community registry"

            desktop_registry_community_search "$@"

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

        update)

            shift

            log_info "Running desktop updater"

            run_desktop_update "$@"

            ;;

        init)

            shift

            log_info "Running desktop profile creator"

            run_desktop_init "$@"

            ;;

        submit)

            shift

            log_info "Submitting to community registry"

            run_desktop_submit "$@"

            ;;

        export)

            shift

            log_info "Exporting installed profile"

            run_desktop_export "$@"

            ;;

        *)

            print_error "Usage: hcc desktop <list|search|install|uninstall|update|init|submit> [name]"

            ;;

    esac

}