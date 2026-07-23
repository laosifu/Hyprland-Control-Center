#!/usr/bin/env bash

desktop_render_summary() {

    print_header "Desktop Package Planner"

    ui_field "Package" "$NAME"
    ui_field "Version" "$VERSION"
    ui_field "Author" "$AUTHOR"

    echo

    ui_field "Reboot" "$REBOOT_REQUIRED"

    echo
}

desktop_generate_install_plan() {

    plan_reset

    desktop_generate_plan

    if [[ "$(plan_size)" -eq 0 ]]
    then

        print_error "Desktop package produced an empty installation plan."

        return 1

    fi

}

desktop_render_plan() {

    print_info "Generated Actions"

    echo

    plan_render

    echo
}

desktop_confirm_execution() {

    echo

    read -rp "Continue installation? [y/N]: " answer

    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            print_warning "Installation cancelled."
            return 1
            ;;
    esac

}

desktop_execute_plan() {

    print_info "Executing plan"

    echo

    desktop_pipeline_run

}

desktop_service_install() {

    local desktop="$1"
    local external_dir=""
    local is_url=false

    if [[ -z "$desktop" ]]; then

        print_error "Desktop package required"

        return 1

    fi

    case "$desktop" in
        https://*|http://*|git@*)
            is_url=true
            print_info "Inspecting external repository: $desktop"
            external_dir="$(mktemp -d)"
            git clone --depth 1 "$desktop" "$external_dir" || {
                rm -rf "$external_dir"
                print_error "Failed to clone repository"
                return 1
            }
            if ! desktop_package_validate_and_load_external "$external_dir"; then
                local repo_owner repo_name fallback_id
                repo_owner="$(basename "$(dirname "$desktop")")"
                repo_name="$(basename "$desktop" .git)"
                for fallback_id in "$repo_name" "$repo_owner"; do
                    if desktop_registry_validate_package "$fallback_id" 2>/dev/null; then
                        print_warning "Repo khong co package.conf, nhung registry co desktop '$fallback_id'."
                        print_info "Dung goi cai san trong HCC thay cho URL."
                        echo
                        rm -rf "$external_dir"
                        desktop_service_install "$fallback_id"
                        return $?
                    fi
                done

                local ext_id="$repo_name"
                local ext_name="$repo_name"

                echo
                print_warning "Repo khong co package.conf hop le."
                print_info "HCC co the clone repo vao external desktop de ban tu cau hinh."
                echo
                print_info "  ID: $ext_id"
                print_info "  URL: $desktop"
                echo
                local answer
                read -rp "Clone vao external desktop? [Y/n]: " answer
                case "$answer" in
                    [Nn]|[Nn][Oo])
                        rm -rf "$external_dir"
                        print_error "External repository does not contain a valid HCC desktop package"
                        print_info "Thu: hcc desktop list (xem desktop co san)"
                        return 1
                        ;;
                esac

                rm -rf "$external_dir"
                if desktop_external_add "$desktop" "$ext_id" "$ext_name"; then
                    echo
                    print_info "Da san sang. Tien hanh cai dat ngay?"
                    local install_now
                    read -rp "Cai dat $ext_id? [Y/n]: " install_now
                    case "$install_now" in
                        [Nn]|[Nn][Oo])
                            print_info "Chay sau: hcc desktop install $ext_id"
                            return 0
                            ;;
                    esac
                    desktop_service_install "$ext_id"
                    return $?
                fi
                return 1

                rm -rf "$external_dir"
                print_error "External repository does not contain a valid HCC desktop package"
                print_info "Thu: hcc desktop list (xem desktop co san)"
                return 1
            fi
            SOURCE_URL="$desktop"
            ;;
        /*|./*|../*)
            external_dir="$desktop"
            if ! desktop_package_validate_and_load_external "$external_dir"; then
                print_error "Directory does not contain a valid HCC desktop package"
                return 1
            fi
            SOURCE_URL="$external_dir"
            ;;
        *)
            if desktop_registry_validate_package "$desktop"; then

                :

            elif desktop_package_load "$desktop"; then

                :

            elif desktop_external_load_package "$desktop"; then

                :

            else

                print_error "Desktop package not found"
                print_info "Use: hcc desktop list (xem desktop co san)"
                print_info "Use: hcc desktop install <url> (cai tu GitHub)"

                return 1

            fi
            SOURCE_URL="local"
            ;;
    esac

    desktop_render_summary

    desktop_generate_install_plan \
||  return 1

    desktop_render_plan

    if plan_detect_conflicts; then
        :
    else
        print_warning "Some destinations already have files. Install will overwrite them."
        echo
    fi

    if ! desktop_confirm_execution; then
        return 0
    fi

    plan_validate || {

    print_error "Generated plan is invalid."

    return 1

}

    desktop_execute_plan || {
        local code=$?
        [[ "$is_url" == true && -d "$external_dir" ]] && rm -rf "$external_dir"
        return $code
    }

    profile_registry_register \
        "$ID" \
        "$NAME" \
        "$VERSION" \
        "${SOURCE_URL:-local}" \
        "${DESKTOP_PREVIOUS_SNAPSHOT:-}" \
    || {
        [[ "$is_url" == true && -d "$external_dir" ]] && rm -rf "$external_dir"
        return 1
    }

    profile_ownership_record_plan "$ID" || {
        [[ "$is_url" == true && -d "$external_dir" ]] && rm -rf "$external_dir"
        return 1
    }

    profile_registry_activate "$ID" || {
        [[ "$is_url" == true && -d "$external_dir" ]] && rm -rf "$external_dir"
        return 1
    }

    print_success "Profile activated: $NAME"

    [[ "$is_url" == true && -d "$external_dir" ]] && rm -rf "$external_dir"

    echo

}
