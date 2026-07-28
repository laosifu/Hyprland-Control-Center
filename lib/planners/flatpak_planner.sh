#!/usr/bin/env bash

planner_flatpak() {
    local app_list="${FLATPAK_PACKAGES:-}"
    local app

    for app in $app_list
    do
        plan_install_flatpak "$app"
    done
}
