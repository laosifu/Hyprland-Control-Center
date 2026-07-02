#!/usr/bin/env bash

plan_execute() {

    local action

    for action in "${PLAN_ACTIONS[@]}"
    do
        plan_execute_action "$action"
    done

}

plan_execute_action() {

    local action="$1"

    local type
    local arg1
    local arg2

    IFS='|' read -r type arg1 arg2 <<< "$action"

    dispatch_action "$type" "$arg1" "$arg2"

}