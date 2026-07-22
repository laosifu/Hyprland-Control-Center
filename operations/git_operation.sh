#!/usr/bin/env bash

git_operation_clone() {

    operation_run \
        git \
        clone \
        "$1" \
        "$2"

}

git_operation_pull() {

    operation_run \
        git \
        -C \
        "$1" \
        pull

}
