#!/usr/bin/env bash

execution_should_abort() {

    local exit_code="$1"

    [[ "$exit_code" -ne 0 ]]

}