#!/usr/bin/env bash

desktop_finalize() {

    desktop_finalize_reload

    desktop_finalize_register_session

    desktop_finalize_message

}

desktop_finalize_reload() {

    return 0

}

desktop_finalize_register_session() {

    local id="${ID:-}"
    local name="${NAME:-}"
    local version="${VERSION:-}"
    local source="${SOURCE_URL:-local}"

    [[ -z "$id" ]] && return 0

    session_register "$id" "$name" "$version" "$source"

    session_isolate "$id"

}

desktop_finalize_message() {

    print_success "Desktop installation completed."

}