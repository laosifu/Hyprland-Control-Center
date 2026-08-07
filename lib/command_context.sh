#!/usr/bin/env bash

CURRENT_COMMAND=""

command_context_set() {

    CURRENT_COMMAND="$*"

}

command_context_get() {

    printf "%s" "$CURRENT_COMMAND"

}