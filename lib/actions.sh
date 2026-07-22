#!/usr/bin/env bash

action_install_package() {

    local package="$1"

    echo "INSTALL_PACKAGE|$package"

}

action_install_aur() {

    local package="$1"

    echo "INSTALL_AUR|$package"

}

action_copy_directory() {

    local source="$1"
    local destination="$2"

    echo "COPY_DIRECTORY|$source|$destination"

}

action_clone_repository() {

    local repository="$1"

    local destination="$2"

    echo "CLONE_REPOSITORY|$repository|$destination"

}
action_backup_directory() {

    local source="$1"

    echo "BACKUP_DIRECTORY|$source"

}