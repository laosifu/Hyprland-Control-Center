#!/usr/bin/env bash

copy_if_exists() {

    local src="$1"
    local dst="$2"

    if [[ -e "$src" ]]; then

        cp -a "$src" "$dst"

        print_success "$src"

    else

        print_warning "$src not found"

    fi

}