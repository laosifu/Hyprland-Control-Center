#!/usr/bin/env bash

package_service_is_installed() {

    package_query_is_installed "$1"

}

package_service_install() {

    local package="${1:-}"

    if package_service_is_installed "$package"
    then

        print_info "Package already installed: $package"

        return 0

    fi

    privilege_require_root_unless_dry_run \
    || return 1

    package_operation_install \
        "$package" \
    || return 1

    transaction_register \
        "package_operation_remove '$package'"

}