#!/usr/bin/env bash

package_handler_install() {

    local package="$1"

    package_service_install "$package"

}