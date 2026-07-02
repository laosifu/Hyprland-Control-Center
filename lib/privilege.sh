#!/usr/bin/env bash

require_root() {

    if [[ "$(id -u)" -eq 0 ]]; then
        return 0
    fi

    print_error "This operation requires root privileges."

    echo

    echo "Run again using:"

    echo

    echo "    sudo hcc $*"

    return 1

}