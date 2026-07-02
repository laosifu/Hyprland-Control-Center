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