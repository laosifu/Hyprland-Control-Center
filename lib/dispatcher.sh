#!/usr/bin/env bash

dispatch_command() {

    local cmd="${1:-help}"

    shift || true

    case "$cmd" in

        doctor)

            log_info "Running doctor"

            run_doctor "$@"

            ;;

        cleanup)

            log_info "Running cleanup"

            run_cleanup "$@"

            ;;

        backup)

            log_info "Running backup"

            run_backup "$@"

            ;;

        restore)

            log_info "Running restore"

            run_restore "$@"

            ;;

        inventory)

            log_info "Running inventory"

            run_inventory "$@"

            ;;

        plugins)

            log_info "Running plugin manager"

            run_plugins "$@"

            ;;
        desktop)

    case "${1:-}" in

        install)

            shift
            run_desktop_install "$@"
            ;;

        *)

            print_error "Usage: hcc desktop install <name>"
            ;;

    esac

    ;;
        plugin)

            case "${1:-}" in

                install)

                    shift

                    log_info "Running plugin installer"

                    run_plugin_install "$@"

                    ;;

                *)

                    print_error "Usage: hcc plugin install <name>"

                    ;;

            esac

            ;;
            

        theme)

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

                *)

                    print_error "Usage: hcc theme list"

                    ;;

            esac

            ;;
            

        --version)

            echo "Hyprland Control Center v$VERSION"

            ;;

        help)

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