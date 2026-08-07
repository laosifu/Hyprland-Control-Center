#!/usr/bin/env bash

print_header() {

    local title="$1"

    echo
    printf '=%.0s' {1..40}
    echo
    echo "$title"
    printf '=%.0s' {1..40}
    echo

}

print_info() {

    echo "$1"

}

print_success() {

    echo "[PASS] $1"

}

print_warning() {

    echo "[WARN] $1"

}

print_error() {

    echo "[FAIL] $1"

}
print_status_ok() {

    printf "%s\n" "Valid"

}

print_status_fail() {

    printf "%s\n" "Invalid"

}
