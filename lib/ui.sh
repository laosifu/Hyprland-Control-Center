#!/usr/bin/env bash

ui_header() {

    print_header "$1"

}

ui_section() {

    echo

    print_info "$1"

    echo

}

ui_field() {

    local title="$1"
    local value="$2"

    printf "    %-14s %s\n" \
        "$title" \
        "$value"

}

ui_check() {

    local name="$1"
    local ok="$2"

    printf "    %-20s " "$name"

    if [[ "$ok" == true ]]; then
        printf "[PASS]\n"
    else
        printf "[FAIL]\n"
    fi

}

ui_status() {

    local result="$1"

    printf "    %-12s " "Status"

    if [[ "$result" == true ]]; then

        print_success "Valid"

    else

        print_error "Invalid"

    fi

}
ui_plugin_title() {

    local index="$1"
    local name="$2"

    printf "%2d. %s\n" \
        "$index" \
        "$name"

}

ui_separator() {

    echo

}