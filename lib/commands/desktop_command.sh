#!/usr/bin/env bash

desktop_dispatch() {

    case "${1:-}" in

        install)

            shift

            log_info "Running desktop installer"

            run_desktop_install "$@"

            ;;

        *)

            print_error "Usage: hcc desktop install <name>"

            ;;

    esac

}