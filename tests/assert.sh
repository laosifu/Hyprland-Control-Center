#!/usr/bin/env bash

PASS_COUNT=0
FAIL_COUNT=0

assert_success() {

    local title="$1"
    shift

    if "$@" >/dev/null 2>&1; then

        echo "[PASS] $title"

        ((++PASS_COUNT))

    else

        echo "[FAIL] $title"

        ((++FAIL_COUNT))

    fi

}

print_summary() {

    echo
    echo "=============================="

    echo "$PASS_COUNT passed"

    echo "$FAIL_COUNT failed"

}