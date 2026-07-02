#!/usr/bin/env bash

filesystem_handler_copy() {

    local source="$1"
    local destination="$2"

    printf "[COPY] %s\n" "$source"
    printf "       -> %s\n" "$destination"

}