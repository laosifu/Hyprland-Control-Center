#!/usr/bin/env bash

LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/hcc.log"

log() {
    local level="$1"
    shift

    printf "[%s] %s\n" "$level" "$*" | tee -a "$LOG_FILE"
}

log_info() {
    log INFO "$@"
}

log_warn() {
    log WARN "$@"
}

log_error() {
    log ERROR "$@"
}
