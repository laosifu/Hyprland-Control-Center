plan_show_diff() {
    local action
    local has_diff=false

    for action in "${PLAN_ACTIONS[@]}"
    do
        plan_record_read "$action"

        case "$PLAN_RECORD_TYPE" in

            COPY_DIRECTORY)
                local dest="${PLAN_RECORD_ARG2}/$(basename "$PLAN_RECORD_ARG1")"
                local src="$PLAN_RECORD_ARG1"

                if [[ ! -e "$dest" ]]; then
                    continue
                fi

                if [[ -d "$dest" && -d "$src" ]]; then
                    local diff_output
                    diff_output=$(diff -rq "$dest" "$src" 2>/dev/null) || true
                    if [[ -n "$diff_output" ]]; then
                        has_diff=true
                        if ! $has_diff; then
                            print_header "Thay doi config"
                            has_diff=true
                        fi
                        ui_field "Config" "$dest"
                        echo "$diff_output" | head -20 | while IFS= read -r line; do
                            echo "    $line"
                        done
                        echo
                    fi
                elif [[ -f "$dest" && -f "$src" ]]; then
                    local file_diff
                    file_diff=$(diff -u "$dest" "$src" 2>/dev/null) || true
                    if [[ -n "$file_diff" ]]; then
                        has_diff=true
                        if ! $has_diff; then
                            print_header "Thay doi config"
                            has_diff=true
                        fi
                        ui_field "File" "$dest"
                        echo "$file_diff" | head -30 | while IFS= read -r line; do
                            echo "    $line"
                        done
                        echo
                    fi
                fi
                ;;

            CLONE_REPOSITORY)
                if [[ -d "$PLAN_RECORD_ARG2" ]]; then
                    local repo_diff
                    repo_diff=$(cd "$PLAN_RECORD_ARG2" 2>/dev/null && git diff --stat 2>/dev/null) || true
                    if [[ -n "$repo_diff" ]]; then
                        has_diff=true
                        if ! $has_diff; then
                            print_header "Thay doi config"
                            has_diff=true
                        fi
                        ui_field "Git repo" "$PLAN_RECORD_ARG2"
                        echo "$repo_diff" | while IFS= read -r line; do
                            echo "    $line"
                        done
                        echo
                    fi
                fi
                ;;
        esac
    done

    [[ "$has_diff" == false ]] && print_success "Khong co thay doi config nao."

    return 0
}
