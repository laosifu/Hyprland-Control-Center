#!/usr/bin/env bash

EXECUTION_TOTAL=0
EXECUTION_CURRENT=0

execution_monitor_reset() {

    EXECUTION_TOTAL=0
    EXECUTION_CURRENT=0

}

execution_monitor_start() {

    EXECUTION_TOTAL="$1"
    EXECUTION_CURRENT=0

}

execution_monitor_next() {

    EXECUTION_CURRENT=$((EXECUTION_CURRENT + 1))

}

execution_monitor_print() {

    local label="$1"

    printf "[%d/%d] %s\n" \
        "$EXECUTION_CURRENT" \
        "$EXECUTION_TOTAL" \
        "$label"

}

execution_monitor_before_action() {

    local type="$1"
    local target="$2"

    printf " -> %s\n" "$target"

}

execution_monitor_after_success() {

    print_success "OK"

}

execution_monitor_after_failure() {

    print_error "FAILED"

}