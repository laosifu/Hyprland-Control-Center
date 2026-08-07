#!/usr/bin/env bash

run_themes() {

    ui_header "Theme Manager"

    ui_section "Installed themes"

    local count=0

    while read -r theme
    do

        [[ -z "$theme" ]] && continue

        ((++count))

        render_theme \
            "$count" \
            "$theme"

    done < <(list_themes)

    echo

    print_info "Total themes: $count"

}