#!/usr/bin/env bash

package_service_install() {

    local package="$1"

    command_run \
        pacman \
        -S \
        --needed \
        "$package"

}