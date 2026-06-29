#!/usr/bin/env bash
render_plugin_metadata() {

    local plugin="$1"

    ui_field \
        "Version" \
         "$PLUGIN_VERSION"

    ui_field \
        "Author" \
        "$PLUGIN_AUTHOR"

    ui_field \
        "Description" \
         "$PLUGIN_DESCRIPTION"

}
render_plugin_status() {

    local plugin="$1"

    if plugin_validate "$plugin"; then

        ui_status true

    else

        ui_status false

    fi

}
render_plugin() {

    local index="$1"

    local plugin="$2"

    local name

    plugin_load "$plugin"

    if plugin_exists "$plugin"; then

        name="$PLUGIN_NAME"

    else

        name="$(basename "$plugin")"

    fi

    ui_plugin_title \
        "$index" \
        "$name"

    render_plugin_status "$plugin"

    if plugin_exists "$plugin"; then

        render_plugin_metadata "$plugin"

    fi

    show_dependencies "$plugin"

    ui_separator

}