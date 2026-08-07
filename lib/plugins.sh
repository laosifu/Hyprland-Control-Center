#!/usr/bin/env bash

plugin_root() {

    echo "$PROJECT_ROOT/plugins"

}
list_plugins() {

    local root

    root="$(plugin_root)"

    [[ -d "$root" ]] || return

    find "$root" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        | sort

}
plugin_config() {

    local plugin="$1"

    echo "$plugin/plugin.conf"

}
plugin_exists() {

    local plugin="$1"

    [[ -f "$(plugin_config "$plugin")" ]]

}
plugin_value() {

    local plugin="$1"

    local key="$2"

    local config

    config="$(plugin_config "$plugin")"

    grep "^${key}=" "$config" \
        | cut -d= -f2- \
        | tr -d '"'

}
plugin_has_config() {

    local plugin="$1"

    [[ -f "$plugin/plugin.conf" ]]

}
plugin_has_install() {

    local plugin="$1"

    [[ -f "$plugin/install.sh" ]]

}
plugin_has_uninstall() {

    local plugin="$1"

    [[ -f "$plugin/uninstall.sh" ]]

}
plugin_has_requirements() {

    local plugin="$1"

    [[ -f "$plugin/requirements.conf" ]]

}
plugin_validate() {

    local plugin="$1"

    plugin_has_config "$plugin" &&
    plugin_has_install "$plugin" &&
    plugin_has_uninstall "$plugin" &&
    plugin_has_requirements "$plugin"

}
plugin_load() {

    local plugin="$1"

    if ! plugin_exists "$plugin"; then

        PLUGIN_NAME=""
        PLUGIN_VERSION=""
        PLUGIN_AUTHOR=""
        PLUGIN_DESCRIPTION=""

        return

    fi

    local file

    file="$plugin/plugin.conf"

    # shellcheck disable=SC1090
    source "$file"

    PLUGIN_NAME="$NAME"

    PLUGIN_VERSION="$VERSION"

    PLUGIN_AUTHOR="$AUTHOR"

    PLUGIN_DESCRIPTION="$DESCRIPTION"

}