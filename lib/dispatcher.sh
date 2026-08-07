#!/usr/bin/env bash

dispatch_command() {

    local cmd="${1:-tui}"

    shift || true

    case "$cmd" in

        doctor)

            doctor_dispatch "$@"

            ;;

        cleanup)

            cleanup_dispatch "$@"

            ;;

        backup)

            backup_dispatch "$@"

            ;;

        restore)

            restore_dispatch "$@"

            ;;

        get)

            shift

            log_info "Running super command: get"

            run_get "$@"

            ;;

        inventory)

            inventory_dispatch "$@"

            ;;

        plugins)

            plugins_dispatch "$@"

            ;;

        desktop)

            desktop_dispatch "$@"

            ;;

        profile)

            profile_dispatch "$@"

            ;;

        inspect)

            inspect_dispatch "$@"

            ;;

        plugin)

            plugin_dispatch "$@"

            ;;

        theme)

            theme_dispatch "$@"

            ;;

        ai)

            ai_dispatch "$@"

            ;;

        session)

            session_dispatch "$@"

            ;;

        self-update)

            self_update_dispatch "$@"

            ;;

        uninstall)

            run_uninstall "$@"

            ;;

        tui|interactive)

            tui_dispatch "$@"

            ;;

        --version)

            echo "Hyprland Control Center v$VERSION"

            ;;

        help|--help)

            show_help

            ;;

        *)

            print_error "Unknown command: $cmd"

            echo

            show_help

            exit 1

            ;;

    esac

}
