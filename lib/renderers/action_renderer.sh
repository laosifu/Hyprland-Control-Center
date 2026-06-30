#!/usr/bin/env bash

render_action() {

    local action="$1"

    IFS='|' read -r type arg1 arg2 <<< "$action"

    case "$type" in

        INSTALL_PACKAGE)

            ui_field "Install" "$arg1"
            ;;

        INSTALL_AUR)

            ui_field "Install AUR" "$arg1"
            ;;

        COPY_DIRECTORY)

            ui_field "Copy" "$arg1"
            ;;

        CLONE_REPOSITORY)

            ui_field "Clone" "$arg1"

            ui_field "Destination" "$arg2"

            ;;

    esac

}