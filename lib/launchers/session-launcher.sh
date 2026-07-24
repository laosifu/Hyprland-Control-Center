#!/usr/bin/env bash
# HCC Session Launcher
# Called by /usr/share/wayland-sessions/hcc-<id>.desktop or hcc.desktop (generic)
# Generic mode (no args): reads the active session from session-active file.
# Specific mode (arg): deploys session <id> directly.

set -euo pipefail

SESSION_ID="${1:-}"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
HCC_SESSION_ACTIVE_FILE="$XDG_CONFIG_HOME/hcc/session-active"

# Generic mode: read active session
if [[ -z "$SESSION_ID" ]]; then
    if [[ -f "$HCC_SESSION_ACTIVE_FILE" ]]; then
        SESSION_ID="$(head -n 1 "$HCC_SESSION_ACTIVE_FILE")"
    fi
    if [[ -z "$SESSION_ID" ]]; then
        echo "HCC: No active session found."
        echo "Install a desktop first or run: hcc session switch"
        exit 1
    fi
fi

HCC_SESSION_BASE="$XDG_CONFIG_HOME/hcc/sessions"
SESSION_DIR="$HCC_SESSION_BASE/$SESSION_ID"
SESSION_ROOT="$SESSION_DIR/root"
MANIFEST="$SESSION_DIR/manifest"

echo "HCC Session: $SESSION_ID"

# Deploy session symlinks
if [[ -f "$MANIFEST" ]]; then
    while IFS= read -r rel_path
    do
        [[ -z "$rel_path" ]] && continue
        target="$HOME/$rel_path"
        source="$SESSION_ROOT/$rel_path"
        if [[ -e "$source" ]]; then
            mkdir -p "$(dirname "$target")"
            ln -sfn "$source" "$target"
        fi
    done < "$MANIFEST"
fi

# Mark active
mkdir -p "$(dirname "$HCC_SESSION_ACTIVE_FILE")"
printf '%s\n' "$SESSION_ID" > "$HCC_SESSION_ACTIVE_FILE"

# Find Hyprland config
HYPR_CONF=""
for path in \
    "$SESSION_ROOT/.config/hypr/hyprland.lua" \
    "$SESSION_ROOT/.config/hypr/hyprland.conf" \
    "$SESSION_ROOT/hypr/hyprland.lua" \
    "$SESSION_ROOT/hypr/hyprland.conf"
do
    [[ -f "$path" ]] && { HYPR_CONF="$path"; break; }
done

[[ -z "$HYPR_CONF" ]] && {
    echo "No Hyprland config found in session: $SESSION_ID"
    exit 1
}

echo "Config: $HYPR_CONF"

exec Hyprland --config "$HYPR_CONF"
