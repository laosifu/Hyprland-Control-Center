#!/usr/bin/env bash

git_service_clone() {

    local repository="$1"
    local destination="$2"

    destination="${destination/#\~/$HOME}"

    git_operation_clone \
        "$repository" \
        "$destination" \
    || return 1

    transaction_register \
        "rm -rf \"$destination\""

}

git_service_update() {

    local directory="$1"

    directory="${directory/#\~/$HOME}"

    git_operation_pull \
        "$directory"

}

git_service_repository_exists() {

    local directory="$1"

    directory="${directory/#\~/$HOME}"

    [[ -d "$directory/.git" ]]

}

git_service_clone_or_update() {

    local repository="$1"
    local destination="$2"

    destination="${destination/#\~/$HOME}"

    if git_service_repository_exists "$destination"
    then

        git_service_update "$destination"

    elif [[ -d "$destination" ]]; then

        rm -rf "$destination"
        git_service_clone \
            "$repository" \
            "$destination"

    else

        git_service_clone \
            "$repository" \
            "$destination"

    fi

}