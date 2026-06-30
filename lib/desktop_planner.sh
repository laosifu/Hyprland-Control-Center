#!/usr/bin/env bash

desktop_generate_plan() {

    local package

    local repository

    local url

    local destination

    #
    # Pacman
    #
    for package in $PACMAN_PACKAGES
    do
        plan_add "$(action_install_package "$package")"
    done

    #
    # AUR
    #
    for package in $AUR_PACKAGES
    do
        plan_add "$(action_install_aur "$package")"
    done

    #
    # Git repositories
    #
    while read -r repository
    do

        [[ -z "$repository" ]] && continue

        IFS='|' read -r url destination <<< "$repository"

        plan_add "$(action_clone_repository "$url" "$destination")"\
           

    done <<< "$GIT_REPOSITORIES"

}