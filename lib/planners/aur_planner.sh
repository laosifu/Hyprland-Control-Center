#!/usr/bin/env bash

planner_aur() {

    local package

    for package in ${AUR_PACKAGES:-}
    do
        plan_install_aur "$package"
    done

}
