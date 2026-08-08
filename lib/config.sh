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

config_set_value() {

    local key="$1"
    local value="$2"
    local tmp

    ensure_config

    tmp="$(mktemp)"
    if grep -q "^[[:space:]]*${key}=" "$CONFIG_FILE" 2>/dev/null; then
        sed "s|^[[:space:]]*${key}=.*|${key}=${value}|" "$CONFIG_FILE" > "$tmp"
    else
        cp "$CONFIG_FILE" "$tmp"
        printf '\n%s=%s\n' "$key" "$value" >> "$tmp"
    fi
    [[ "$(tail -c 1 "$tmp" | wc -l)" -eq 1 ]] || printf '\n' >> "$tmp"
    mv "$tmp" "$CONFIG_FILE"
}