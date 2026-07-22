#!/usr/bin/env bash

PASS_COUNT=0
FAIL_COUNT=0

assert_success() {

    local title="$1"
    shift

    if "$@" >/dev/null 2>&1
    then

        echo "[PASS] $title"
        ((++PASS_COUNT))

    else

        echo "[FAIL] $title"
        ((++FAIL_COUNT))

    fi

}

assert_failure() {

    local title="$1"
    shift

    if "$@" >/dev/null 2>&1
    then

        echo "[FAIL] $title"
        ((++FAIL_COUNT))

    else

        echo "[PASS] $title"
        ((++PASS_COUNT))

    fi

}

assert_equals() {

    local title="$1"
    local expected="$2"
    local actual="$3"

    if [[ "$expected" == "$actual" ]]
    then

        echo "[PASS] $title"
        ((++PASS_COUNT))

    else

        echo "[FAIL] $title"
        echo " expected: $expected"
        echo " actual:   $actual"
        ((++FAIL_COUNT))

    fi

}

print_summary() {

    echo
    echo "=============================="

    echo "$PASS_COUNT passed"
    echo "$FAIL_COUNT failed"

    [[ "$FAIL_COUNT" -eq 0 ]]

}