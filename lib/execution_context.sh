#!/usr/bin/env bash

#
# Command Context
#

COMMAND_CONTEXT=()

execution_set_command_context() {

    COMMAND_CONTEXT=("$@")

}

#
# Execution Flags
#

EXECUTION_DRY_RUN=false
EXECUTION_VERBOSE=false
EXECUTION_ASSUME_YES=false

#
# Dry Run
#

execution_set_dry_run() {

    EXECUTION_DRY_RUN="$1"

}

execution_is_dry_run() {

    [[ "$EXECUTION_DRY_RUN" == true ]]

}

#
# Verbose
#

execution_set_verbose() {

    EXECUTION_VERBOSE="$1"

}

execution_is_verbose() {

    [[ "$EXECUTION_VERBOSE" == true ]]

}

#
# Assume Yes
#

execution_set_assume_yes() {

    EXECUTION_ASSUME_YES="$1"

}

execution_is_assume_yes() {

    [[ "$EXECUTION_ASSUME_YES" == true ]]

}