#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/hcc"

CONFIG_FILE="$CONFIG_DIR/config.conf"

DEFAULT_CONFIG="$PROJECT_ROOT/config/default.conf"

ensure_config() {

    mkdir -p "$CONFIG_DIR"

    if [[ ! -f "$CONFIG_FILE" ]]; then

        cp "$DEFAULT_CONFIG" "$CONFIG_FILE"

        log_info "Created default configuration"

    fi

}

load_config() {

    ensure_config

    # shellcheck disable=SC1090
    source "$CONFIG_FILE"

}
get_backup_dir() {

    echo "${BACKUP_DIR/\$HOME/$HOME}"

}