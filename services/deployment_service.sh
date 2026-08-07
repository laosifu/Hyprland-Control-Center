deployment_service_execute_plan() {
    plan_validate || return 1

    execution_monitor_reset
    runtime_reset
    runtime_set_total "$(plan_size)"
    transaction_reset

    local action
    local status

    for action in "${PLAN_ACTIONS[@]}"; do
        execution_monitor_next

        plan_execute_action "$action"

        status=$?

        if execution_should_abort "$status"; then
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
