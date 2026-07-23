render_desktop() {
    local index="$1"
    local id="$2"
    if desktop_registry_load_package "$id"; then
        ui_plugin_title "$index" "$NAME"
        ui_field "ID" "$ID"
        ui_field "Version" "$VERSION"
        ui_field "Author" "$AUTHOR"
    else
        ui_plugin_title "$index" "$id"
        ui_status false
    fi
    ui_separator
}
