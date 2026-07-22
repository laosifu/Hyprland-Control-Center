#!/usr/bin/env bash

plan_validate_action() {

    local action="$1"

    local type
    local arg1
    local arg2

    IFS='|' read -r type arg1 arg2 <<< "$action"

    case "$type" in

        INSTALL_PACKAGE)

            [[ -n "$arg1" ]]
            ;;

        INSTALL_AUR)

            [[ -n "$arg1" ]]
            ;;

        CLONE_REPOSITORY)

            [[ -n "$arg1" && -n "$arg2" ]]
            ;;

        COPY_DIRECTORY)

            [[ -n "$arg1" && -n "$arg2" ]]
            ;;

        *)

            return 1
            ;;

    esac

}

plan_validate() {

    plan_foreach plan_validate_action

}