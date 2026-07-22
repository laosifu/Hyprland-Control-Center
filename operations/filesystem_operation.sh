#!/usr/bin/env bash

filesystem_operation_create_directory() {

    operation_run \
        mkdir \
        -p \
        "$1"

}

filesystem_operation_remove() {

    operation_run \
        rm \
        -rf \
        "$1"

}

filesystem_operation_copy_directory() {

    local source="$1"
    local destination="$2"

    operation_run \
        cp \
        -a \
        "$source/." \
        "$destination/"

}