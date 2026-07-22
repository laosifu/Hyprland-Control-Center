#!/usr/bin/env bash

aur_service_is_installed() {

    aur_query_is_installed "$1"

}

aur_service_install() {

    local package="$1"

    if aur_service_is_installed "$package"
    then

        print_info "AUR package already installed: $package"

        return 0

    fi

    privilege_require_root_unless_dry_run \
    || return 1

    aur_operation_install_package \
        "$package"

}