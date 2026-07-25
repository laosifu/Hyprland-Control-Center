#!/usr/bin/env bash

planner_package() {
    local pkg_list="${PACKAGES:-${PACMAN_PACKAGES:-}}"
    local pkg

    for pkg in $pkg_list
    do
        plan_install_package "$pkg"
    done
}
