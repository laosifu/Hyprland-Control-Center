#!/usr/bin/env bash

dispatch_action() {

    local action="$1"

    plan_record_read "$action"

    local dest_arg
    local session_root_dir

    if [[ -n "${SESSION_INSTALL_ID:-}" ]]; then
        session_root_dir="$(session_root "$SESSION_INSTALL_ID")"
        mkdir -p "$session_root_dir" 2>/dev/null || true
    fi

    case "$PLAN_RECORD_TYPE" in

        INSTALL_PACKAGE)

            package_service_install \
                "$PLAN_RECORD_ARG1"
            ;;

        INSTALL_AUR)

            aur_service_install \
                "$PLAN_RECORD_ARG1"
            ;;

        CLONE_REPOSITORY)

            dest_arg="$PLAN_RECORD_ARG2"

            if [[ -n "$session_root_dir" ]]; then
                dest_arg="${dest_arg/#\~/$HOME}"
                if [[ "$dest_arg" == "$HOME" ]]; then
                    dest_arg="$session_root_dir"
                elif [[ "$dest_arg" == "$HOME/"* ]]; then
                    dest_arg="$session_root_dir/${dest_arg#$HOME/}"
                fi
            fi

            git_service_clone_or_update \
                "$PLAN_RECORD_ARG1" \
                "$dest_arg"
            ;;

        COPY_DIRECTORY)

            dest_arg="$PLAN_RECORD_ARG2"

            if [[ -n "$session_root_dir" ]]; then
                dest_arg="${dest_arg/#\~/$HOME}"
                if [[ "$dest_arg" == "$HOME" ]]; then
                    dest_arg="$session_root_dir"
                elif [[ "$dest_arg" == "$HOME/"* ]]; then
                    dest_arg="$session_root_dir/${dest_arg#$HOME/}"
                fi
            fi

            filesystem_service_copy_directory \
                "$PLAN_RECORD_ARG1" \
                "$dest_arg"
            ;;

        *)

            print_error "Unknown action: $PLAN_RECORD_TYPE"

            return 1
            ;;

    esac

}