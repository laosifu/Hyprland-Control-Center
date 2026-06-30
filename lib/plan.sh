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

plan_render() {

    local action

    for action in "${PLAN_ACTIONS[@]}"
    do

        render_action "$action"

    done

}