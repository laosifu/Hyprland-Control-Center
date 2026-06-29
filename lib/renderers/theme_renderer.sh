#!/usr/bin/env bash

render_theme() {

    local index="$1"
    local theme="$2"

    if ! theme_load "$theme"; then

        ui_plugin_title \
            "$index" \
            "$(basename "$theme")"

        ui_status false

        ui_separator

        return

    fi

    ui_plugin_title \
        "$index" \
        "$NAME"

    ui_field \
        "Version" \
        "$VERSION"

    ui_field \
        "Author" \
        "$AUTHOR"

    ui_field \
        "Description" \
        "$DESCRIPTION"

    ui_separator

}