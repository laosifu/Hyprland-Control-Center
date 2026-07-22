#!/usr/bin/env bash

dispatch_desktop() {

    case "${1:-}" in

        install)

            shift

            run_desktop_install "$@"

            ;;

        *)

            print_error "Usage: hcc desktop install <name>"

            ;;

    esac

}