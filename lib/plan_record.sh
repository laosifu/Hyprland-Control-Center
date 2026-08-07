#!/usr/bin/env bash

plan_record_create() {

    local type="${1:-}"
    local arg1="${2:-}"
    local arg2="${3:-}"

    printf "%s|%s|%s\n" \
        "$type" \
        "$arg1" \
        "$arg2"

}

plan_record_type() {

    IFS='|' read -r type _ <<< "$1"

    printf "%s\n" "$type"

}

plan_record_arg1() {

    IFS='|' read -r _ arg1 _ <<< "$1"

    printf "%s\n" "$arg1"

}

plan_record_arg2() {

    IFS='|' read -r _ _ arg2 <<< "$1"

    printf "%s\n" "$arg2"

}
PLAN_RECORD_TYPE=""
PLAN_RECORD_ARG1=""
PLAN_RECORD_ARG2=""

plan_record_read() {

    local record="$1"

    PLAN_RECORD_TYPE="$(plan_record_type "$record")"
    PLAN_RECORD_ARG1="$(plan_record_arg1 "$record")"
    PLAN_RECORD_ARG2="$(plan_record_arg2 "$record")"

}