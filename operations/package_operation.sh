#!/usr/bin/env bash

package_operation_install() {

    operation_run \
        sudo \
        pacman \
        -S \
        --needed \
        "$1"

}