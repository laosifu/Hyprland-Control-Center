#!/usr/bin/env bash

show_dependencies() {

    local plugin="$1"

    requirements_load "$plugin"

    echo

    ui_section "Dependencies"

    echo

    if [[ -n "$REQUIRE_COMMANDS" ]]; then

        print_info "Commands"

        echo

        for cmd in $REQUIRE_COMMANDS
        do

            ui_check \
                "$cmd" \
                "$(dependency_check_command "$cmd" && echo true || echo false)"

        done

        echo

    fi

    if [[ -n "$REQUIRE_PACKAGES" ]]; then

        print_info "Packages"

        echo

        for pkg in $REQUIRE_PACKAGES
        do

            ui_check \
                "$pkg" \
                "$(dependency_check_package "$pkg" && echo true || echo false)"

        done

        echo

    fi

    if [[ -n "$REQUIRE_SERVICES" ]]; then

        print_info "Services"

        echo

        for svc in $REQUIRE_SERVICES
        do

            ui_check \
             "$svc" \
                "$(dependency_check_service "$svc" && echo true || echo false)"

        done

        echo

    fi

}

run_plugins() {

    ui_header "Plugin Manager"

    ui_section "Installed plugins"

    local count=0

    while read -r plugin
    do

        [[ -z "$plugin" ]] && continue

        ((++count))

        render_plugin \
            "$count" \
            "$plugin"

    done < <(list_plugins)

    print_info "Total plugins: $count"

}