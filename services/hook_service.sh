#!/usr/bin/env bash

hook_service_run() {

    local hook="$1"

    [[ -f "$hook" ]] || return 0

    command_run bash "$hook"

}
