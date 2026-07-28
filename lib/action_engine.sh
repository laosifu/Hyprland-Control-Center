action_engine_execute_plan() {
    local plan_size
    plan_size="$(plan_size)"
    local i
    local action
    local exit_code=0

    for ((i=0; i<plan_size; i++)); do
        action="$(plan_get "$i")"

        execution_monitor_start "$((i+1))" "$plan_size"

        if ! dispatch_action "$action"; then
            print_error "Action failed: $(plan_record_type "$action")"
            exit_code=1
            break
        fi

        execution_monitor_end
    done

    execution_monitor_summary

    return "$exit_code"
}

action_engine_execute() {
    dispatch_action "$1"
}
