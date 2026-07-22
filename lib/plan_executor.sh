#!/usr/bin/env bash

plan_execute() {

    execution_monitor_reset

    execution_monitor_start "$(plan_size)"

    runtime_reset

    runtime_set_total "$(plan_size)"

    transaction_reset

    local action
    local status

    for action in "${PLAN_ACTIONS[@]}"
    do

        execution_monitor_next

        plan_execute_action "$action"

        status=$?

        if execution_should_abort "$status"
        then

            print_info "Rolling back..."

            transaction_rollback

            transaction_commit

            runtime_print_summary

            return "$status"

        fi

    done

    runtime_print_summary

    return 0

}

plan_execute_action() {

    local action="$1"

    local status

    plan_record_read "$action"

    execution_monitor_print "$PLAN_RECORD_TYPE"

    runtime_next

    execution_monitor_before_action \
    "$PLAN_RECORD_TYPE" \
    "$PLAN_RECORD_ARG1"

    dispatch_action "$action"

    status=$?

    if [[ "$status" -eq 0 ]]
    then

        runtime_success

        execution_monitor_after_success

    else

        runtime_failed

        execution_monitor_after_failure

    fi

    return "$status"

}