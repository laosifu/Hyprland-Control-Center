#!/usr/bin/env bash

git_service_clone() {

    local repository="$1"
    local destination="$2"

    command_run \
        git \
        clone \
        "$repository" \
        "$destination"

}

git_service_update() {

    local directory="$1"

    command_run \
        git \
        -C \
        "$directory" \
        pull

}