#!/usr/bin/env bash

git_clone_repository() {

    local repository="$1"
    local destination="$2"

    git clone "$repository" "$destination"

}

git_update_repository() {

    local directory="$1"

    (
        cd "$directory" || exit 1
        git pull
    )

}