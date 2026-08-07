#!/usr/bin/env bash

dispatch_action() {

    local action="$1"

    plan_record_read "$action"

    case "$PLAN_RECORD_TYPE" in

        INSTALL_PACKAGE)

            package_service_install \
                "$PLAN_RECORD_ARG1"
            ;;

        INSTALL_FLATPAK)

            operation_run flatpak install -y flathub \
                "$PLAN_RECORD_ARG1"
            ;;

        INSTALL_AUR)

            aur_service_install \
                "$PLAN_RECORD_ARG1"
            ;;

        CLONE_REPOSITORY)

            git_service_clone_or_update \
                "$PLAN_RECORD_ARG1" \
                "$PLAN_RECORD_ARG2"
            ;;

        COPY_DIRECTORY)

            filesystem_service_copy_directory \
                "$PLAN_RECORD_ARG1" \
                "$PLAN_RECORD_ARG2"
            ;;

        *)

            print_error "Unknown action: $PLAN_RECORD_TYPE"

            return 1
            ;;

    esac

}
