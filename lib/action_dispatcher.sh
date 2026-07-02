#!/usr/bin/env bash

dispatch_action() {

    local type="$1"
    local arg1="$2"
    local arg2="$3"

    case "$type" in

        INSTALL_PACKAGE)

            package_service_install "$arg1"
            ;;

        INSTALL_AUR)

            aur_service_install "$arg1"
            ;;

        CLONE_REPOSITORY)

            git_service_clone "$arg1" "$arg2"
            ;;

        COPY_DIRECTORY)

            filesystem_service_copy_directory "$arg1" "$arg2"
            ;;

        *)

            print_error "Unknown action: $type"

            return 1
            ;;

    esac

}