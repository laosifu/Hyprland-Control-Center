#!/usr/bin/env bash
# HCC Session Launcher
# Called by /usr/share/wayland-sessions/hcc.desktop
# Reads the active profile and launches Hyprland.

SESSION_ID="${1:-}"

HCC_USER_HOME="${HCC_REAL_HOME:-$HOME}"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HCC_USER_HOME/.config}"
HCC_ACTIVE_FILE="$XDG_CONFIG_HOME/hcc/session-active"

if [[ -z "$SESSION_ID" ]]; then
    if [[ -f "$HCC_ACTIVE_FILE" ]]; then
        SESSION_ID="$(head -n 1 "$HCC_ACTIVE_FILE")"
    fi
    if [[ -z "$SESSION_ID" ]]; then
        echo "HCC: No active session"
        exit 1
    fi
fi

echo "HCC: $SESSION_ID"

PATH="/usr/bin:/usr/local/bin:$PATH"
export PATH

exec /usr/bin/Hyprland
