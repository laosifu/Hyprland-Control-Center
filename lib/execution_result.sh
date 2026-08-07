#!/usr/bin/env bash

RUNTIME_SUCCESS=0
RUNTIME_FAILED=0

RUNTIME_CURRENT=0
RUNTIME_TOTAL=0

runtime_reset() {

    RUNTIME_SUCCESS=0
    RUNTIME_FAILED=0

    RUNTIME_CURRENT=0
    RUNTIME_TOTAL=0

}

runtime_success() {

    ((++RUNTIME_SUCCESS))

}

runtime_failed() {

    ((++RUNTIME_FAILED))

}

runtime_set_total() {

    RUNTIME_TOTAL="$1"

}

runtime_next() {

    ((++RUNTIME_CURRENT))

}



runtime_print_summary() {

    echo

    print_info "Execution Summary"

    ui_field "Succeeded" "$RUNTIME_SUCCESS"
    ui_field "Failed" "$RUNTIME_FAILED"

    echo

}