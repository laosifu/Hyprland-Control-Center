#!/usr/bin/env bash

render_action() {

    local action="$1"

    local type
    local arg1
    local arg2

    type="$(plan_record_type "$action")"
    arg1="$(plan_record_arg1 "$action")"
    arg2="$(plan_record_arg2 "$action")"

    case "$type" in

        INSTALL_PACKAGE)

            ui_field "Install" "$arg1"
            ;;

        INSTALL_FLATPAK)

            ui_field "Install Flatpak" "$arg1"
            ;;

        INSTALL_AUR)

            ui_field "Install AUR" "$arg1"
            ;;

        COPY_DIRECTORY)

            ui_field "Copy" ""

            ui_field "Source" "$arg1"
            ui_field "Destination" "$arg2"
            ;;

        CLONE_REPOSITORY)

            ui_field "Clone" "$arg1"

            ui_field "Destination" "$arg2"
            ;;

    esac

}