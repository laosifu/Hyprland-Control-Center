#!/usr/bin/env bash

git_handler_clone() {

    local repository="$1"
    local destination="$2"

    printf "[GIT] %s\n" "$repository"
    printf "      -> %s\n" "$destination"

}