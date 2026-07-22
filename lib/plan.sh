#!/usr/bin/env bash

PLAN_ACTIONS=()

plan_reset() {

    PLAN_ACTIONS=()

}

plan_add() {

    PLAN_ACTIONS+=("$1")

}

plan_size() {

    echo "${#PLAN_ACTIONS[@]}"

}
plan_foreach() {

    local callback="$1"

    local action

    for action in "${PLAN_ACTIONS[@]}"
    do
        "$callback" "$action"
    done

}

plan_render() {

    plan_foreach render_action

}
plan_add_install_package() {

    plan_add \
        "$package"

}

plan_add_install_aur() {

    plan_add \
        "$(action_install_aur "$1")"

}

plan_add_copy_directory() {

    plan_add \
        "$(action_copy_directory "$1")"

}

plan_add_clone_repository() {

    plan_add \
        "$(action_clone_repository "$1" "$2")"

}