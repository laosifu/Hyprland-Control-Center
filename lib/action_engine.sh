#!/usr/bin/env bash

action_engine_execute() {

    local action_type="$1"

    shift

    _action_engine_dispatch "$action_type" "$@"

}

_action_engine_dispatch() {

    local action_type="$1"

    shift

    printf '[ACTION] %s\n' "$action_type"

    printf 'Payload: %s\n' "$*"

}