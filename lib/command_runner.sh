#!/usr/bin/env bash

command_run() {

    local command=("$@")

    if execution_is_verbose; then
        printf "[RUN]"
        printf " %q" "${command[@]}"
        echo
    fi

    if execution_is_dry_run; then
        printf "[DRY-RUN]"
        printf " %q" "${command[@]}"
        echo
        return 0
    fi

    "${command[@]}"

}
