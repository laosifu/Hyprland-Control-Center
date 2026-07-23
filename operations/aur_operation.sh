#!/usr/bin/env bash

aur_operation_install_package() {

    local package="$1"

    operation_run \
        yay \
        -S \
        --needed \
        --answerclean None \
        --answerdiff None \
        --answeredit None \
        "$package"

}