#!/usr/bin/env bash
# HCC Session Launcher
# Called by /usr/share/wayland-sessions/hcc.desktop
# Reads the active profile and launches Hyprland.

SESSION_ID="${1:-}"

HCC_USER_HOME="${HCC_REAL_HOME:-$HOME}"

HCC_DATA_DIR="${HCC_DATA_DIR:-$HCC_USER_HOME/.local/share/hcc}"
HCC_PROFILE_ROOT="$HCC_DATA_DIR/profiles"
HCC_ACTIVE_FILE="$HCC_PROFILE_ROOT/active"

if [[ -z "$SESSION_ID" ]]; then
    if [[ -f "$HCC_ACTIVE_FILE" ]]; then
        SESSION_ID="$(head -n 1 "$HCC_ACTIVE_FILE")"
    fi
    if [[ -z "$SESSION_ID" ]]; then
        echo "HCC: No active session" >&2
        exit 1
    fi
fi

echo "HCC: $SESSION_ID"

PATH="/usr/bin:/usr/local/bin:$PATH"
export PATH

if command -v start-hyprland &>/dev/null; then
    exec start-hyprland
fi
if [[ -x "/usr/bin/Hyprland" ]]; then
    exec /usr/bin/Hyprland
fi
if command -v Hyprland &>/dev/null; then
    exec Hyprland
fi

echo "HCC: Hyprland not found" >&2
exit 1
