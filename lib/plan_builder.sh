#!/usr/bin/env bash

plan_install_package() {

    local package="$1"

   plan_add \
    "$(plan_record_create \
        INSTALL_PACKAGE \
        "$package")"

}

plan_install_flatpak() {

    local app="$1"

    plan_add \
    "$(plan_record_create \
        INSTALL_FLATPAK \
        "$app")"

}

plan_install_aur() {

    local package="$1"

    plan_add \
    "$(plan_record_create \
        INSTALL_AUR \
        "$package")"

}

plan_clone_repository() {

    local repository="$1"
    local destination="$2"

    plan_add \
    "$(plan_record_create \
        CLONE_REPOSITORY \
        "$url" \
        "$destination")"

}

plan_copy_directory() {

    local source="$1"
    local destination="$2"

    plan_add \
    "$(plan_record_create \
        COPY_DIRECTORY \
        "$source" \
        "$destination")"

}
plan_backup_directory() {

    local directory="$1"

    plan_add \
        "$(plan_record_create \
           action_backup_directory \
            "$directory")"

}