#!/usr/bin/env bash

planner_package() {

    local package

    for package in ${PACMAN_PACKAGES:-}
    do
        plan_install_package "$package"
    done

}
