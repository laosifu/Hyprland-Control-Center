plan_detect_conflicts() {
    local action
    local conflicts=()
    local count=0

    for action in "${PLAN_ACTIONS[@]}"
    do
        plan_record_read "$action"

        case "$PLAN_RECORD_TYPE" in

            COPY_DIRECTORY)
                local dest="${PLAN_RECORD_ARG2}/$(basename "$PLAN_RECORD_ARG1")"
                if [[ -e "$dest" ]]; then
                    conflicts+=("COPY|$dest")
                    ((++count))
                fi
                ;;

            CLONE_REPOSITORY)
                if [[ -d "$PLAN_RECORD_ARG2" ]]; then
                    conflicts+=("CLONE|${PLAN_RECORD_ARG2}")
                    ((++count))
                fi
                ;;

        esac
    done

    if [[ "$count" -eq 0 ]]; then
        return 0
    fi

    print_warning "Detected $count existing file(s) that will be overwritten:"
    echo
    for conflict in "${conflicts[@]}"
    do
        IFS='|' read -r ctype cpath <<< "$conflict"
        case "$ctype" in
            COPY)   ui_field "Overwrite" "$cpath" ;;
            CLONE)  ui_field "Repo exists" "$cpath" ;;
        esac
    done
    echo

    return 1
}
