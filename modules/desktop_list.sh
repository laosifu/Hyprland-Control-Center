run_desktop_list() {
    ui_header "Desktop Registry"
    ui_section "Available desktops"
    local count=0
    local id
    for id in $(desktop_registry_list)
    do
        [[ -z "$id" ]] && continue
        ((++count))
        render_desktop "$count" "$id"
    done
    echo
    print_info "Total: $count desktop(s)"
}
