#!/usr/bin/env bash

desktop_plan_package_count() {

    wc -w <<< "$PACMAN_PACKAGES"

}

desktop_plan_aur_count() {

    wc -w <<< "$AUR_PACKAGES"

}

desktop_plan_directory_count() {

    wc -w <<< "$COPY_DIRECTORIES"

}

desktop_plan_repository_count() {

    wc -l <<< "$GIT_REPOSITORIES"

}