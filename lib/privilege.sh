#!/usr/bin/env bash

privilege_require_root() {

    if [[ "$(id -u)" -eq 0 ]]; then
        return 0
    fi

    print_error "This operation requires root privileges."

    echo

    echo "Run again using:"

    echo

    echo "    sudo hcc ${COMMAND_CONTEXT[*]}"

    return 1

}

privilege_require_root_unless_dry_run() {

    if execution_is_dry_run; then
        return 0
    fi

    privilege_require_root

}
privilege_run_root() {

    if execution_is_dry_run
    then

        "$@"

        return

    fi

    sudo "$@"

}
