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
        echo
        print_info "package.conf thieu PACMAN_PACKAGES, AUR_PACKAGES, GIT_REPOSITORIES, hoac COPY_ITEMS."
        print_info "Chinh sua: $(desktop_external_package_file "${ID:-}" 2>/dev/null || echo "package.conf")"
        print_info "Sau do chay lai: hcc desktop install ${ID:-<ten>}"

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
                print_info "Dang tu dong phan tich repo..."
                echo

                rm -rf "$external_dir"

                local ext_dir
                ext_dir="$(desktop_external_package_dir "$ext_id")"

                if desktop_external_exists "$ext_id"; then
                    print_warning "Desktop '$ext_id' da ton tai: $ext_dir"
                else
                    mkdir -p "$ext_dir" || return 1
                    print_info "Cloning repo to: $ext_dir"
                    git clone --depth 1 "$desktop" "$ext_dir" || {
                        rm -rf "$ext_dir"
                        print_error "Failed to clone repository"
                        return 1
                    }
                    print_success "Da clone repo vao: $ext_dir"
                fi

                if desktop_external_generate_package_conf "$ext_dir" "$ext_id" "$ext_name" "$desktop" "auto"; then
                    print_info "Tien hanh cai dat..."
                    echo
                    desktop_service_install "$ext_id"
                    return $?
                fi

                print_warning "Khong the tu dong phat hien packages."
                echo
                local help_loop=true
                while [[ "$help_loop" == true ]]; do
                    print_info "=== Khong phat hien duoc packages ==="
                    echo
                    print_info "  1) Huong dan dinh dang package.conf"
                    print_info "  2) Chay script cai dat tu repo (install.sh/setup.sh) + tu dong phat hien"
                    print_info "  3) Mo editor soan package.conf thu cong"
                    print_info "  0) Huy, de tu cau hinh tay sau"
                    echo
                    local choice
                    read -rp "Chon [1/2/3/0] (Enter=3): " choice
                    case "$choice" in
                        1)
                            desktop_external_show_package_conf_help
                            echo
                            read -rp "Enter de quay lai menu..."
                            ;;
                        2)
                            if desktop_external_run_script_and_detect "$ext_dir" "$ext_id" "$ext_name" "$desktop"; then
                                print_info "Tien hanh cai dat..."
                                echo
                                desktop_service_install "$ext_id"
                                return $?
                            fi
                            ;;
                        3|"")
                            desktop_external_edit_package_conf "$ext_id"
                            echo
                            print_info "Thu lai ngay..."
                            desktop_service_install "$ext_id"
                            return $?
                            ;;
                        0|q|cancel)
                            print_info "Tu tao: $ext_dir/package.conf"
                            print_info "Sau do chay: hcc desktop install $ext_id"
                            return 0
                            ;;
                    esac
                done
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

    if ! desktop_generate_install_plan; then

        if desktop_external_exists "${ID:-}" 2>/dev/null; then
            echo
            local edit_answer
            read -rp "Mo package.conf de chinh sua? [Y/n]: " edit_answer
            case "$edit_answer" in
                [Nn]|[Nn][Oo])
                    return 1
                    ;;
            esac
            desktop_external_edit_package_conf "$ID"
            echo
            print_info "Thu lai ngay..."
            desktop_service_install "$ID"
            return $?
        fi
        return 1

    fi

    desktop_render_plan

    if plan_detect_conflicts; then
        :
    else
        print_warning "Some destinations already have files. Install will overwrite them."
        echo
    fi

    plan_show_diff

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

    profile_registry_activate "$ID" || {
        [[ "$is_url" == true && -d "$external_dir" ]] && rm -rf "$external_dir"
        return 1
    }

    print_success "Profile activated: $NAME"

    [[ "$is_url" == true && -d "$external_dir" ]] && rm -rf "$external_dir"

    echo

}
