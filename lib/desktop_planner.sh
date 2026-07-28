#!/usr/bin/env bash

desktop_generate_plan() {

    local package
    local repository
    local url
    local destination
    local item
    local source
    local target

    plan_reset

    #
    # Pacman
    #
    planner_package

    #
    # Flatpak
    #
    planner_flatpak

    #
    # AUR
    #
    planner_aur

    #
    # Git
    #
    planner_git <<< "${GIT_REPOSITORIES:-}"

    #
    # Copy Items
    #
    planner_copy <<< "${COPY_ITEMS:-}"

}