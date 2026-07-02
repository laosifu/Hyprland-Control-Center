#!/usr/bin/env bash

EXECUTION_DRY_RUN=false
EXECUTION_VERBOSE=false
EXECUTION_ASSUME_YES=false

execution_reset() {

    EXECUTION_DRY_RUN=false
    EXECUTION_VERBOSE=false
    EXECUTION_ASSUME_YES=false

}

execution_set_dry_run() {

    EXECUTION_DRY_RUN="$1"

}

execution_is_dry_run() {

    [[ "$EXECUTION_DRY_RUN" == true ]]

}

execution_set_verbose() {

    EXECUTION_VERBOSE="$1"

}

execution_is_verbose() {

    [[ "$EXECUTION_VERBOSE" == true ]]

}

execution_set_assume_yes() {

    EXECUTION_ASSUME_YES="$1"

}

execution_is_assume_yes() {

    [[ "$EXECUTION_ASSUME_YES" == true ]]

}