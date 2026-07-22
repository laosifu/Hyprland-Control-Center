#!/usr/bin/env bash

planner_git() {

    local repository
    local url
    local destination

    while read -r repository
    do

        [[ -z "$repository" ]] && continue

        IFS='|' read -r url destination <<< "$repository"

        plan_clone_repository \
            "$url" \
            "$destination"

    done <<< "$GIT_REPOSITORIES"

}
