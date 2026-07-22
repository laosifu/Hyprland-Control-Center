#!/usr/bin/env bash

plugin_dispatch() {

    case "${1:-}" in

        install)

            shift

            log_info "Running plugin installer"

            run_plugin_install "$@"

            ;;

        uninstall)

            shift

            log_info "Running plugin uninstaller"

            run_plugin_uninstall "$@"

            ;;

        *)

            print_error "Usage: hcc plugin <install|uninstall> <name>"

            ;;

    esac

}
