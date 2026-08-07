#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PROJECT_ROOT/tests/lib/bootstrap.sh"
VERSION="$(<"$PROJECT_ROOT/VERSION")"

PASS_COUNT=0
FAIL_COUNT=0

# ============================================================
# Test: plan_install_flatpak creates correct plan record
# ============================================================
plan_reset
plan_install_flatpak "org.mozilla.firefox"
record="$(plan_record_type "${PLAN_ACTIONS[0]:-}")"
if [[ "$record" == "INSTALL_FLATPAK" ]]; then
    echo "[PASS] plan_install_flatpak creates INSTALL_FLATPAK"
    ((++PASS_COUNT))
else
    echo "[FAIL] plan_install_flatpak type: $record" >&2
    ((++FAIL_COUNT))
fi

arg="$(plan_record_arg1 "${PLAN_ACTIONS[0]:-}")"
if [[ "$arg" == "org.mozilla.firefox" ]]; then
    echo "[PASS] plan_install_flatpak arg1 = org.mozilla.firefox"
    ((++PASS_COUNT))
else
    echo "[FAIL] plan_install_flatpak arg1: $arg" >&2
    ((++FAIL_COUNT))
fi

# ============================================================
# Test: planner_flatpak iterates FLATPAK_PACKAGES
# ============================================================
plan_reset
FLATPAK_PACKAGES="org.mozilla.firefox org.keepassxc.KeePassXC"
planner_flatpak
size="$(plan_size)"
if [[ "$size" -eq 2 ]]; then
    echo "[PASS] planner_flatpak creates 2 actions for 2 packages"
    ((++PASS_COUNT))
else
    echo "[FAIL] planner_flatpak size: $size (expected 2)" >&2
    ((++FAIL_COUNT))
fi

arg0="$(plan_record_arg1 "${PLAN_ACTIONS[0]:-}")"
arg1="$(plan_record_arg1 "${PLAN_ACTIONS[1]:-}")"
if [[ "$arg0" == "org.mozilla.firefox" && "$arg1" == "org.keepassxc.KeePassXC" ]]; then
    echo "[PASS] planner_flatpak args match FLATPAK_PACKAGES order"
    ((++PASS_COUNT))
else
    echo "[FAIL] planner_flatpak arg order: $arg0, $arg1" >&2
    ((++FAIL_COUNT))
fi

# ============================================================
# Test: empty FLATPAK_PACKAGES produces no actions
# ============================================================
plan_reset
FLATPAK_PACKAGES=""
planner_flatpak
size="$(plan_size)"
if [[ "$size" -eq 0 ]]; then
    echo "[PASS] planner_flatpak handles empty FLATPAK_PACKAGES"
    ((++PASS_COUNT))
else
    echo "[FAIL] planner_flatpak size with empty: $size" >&2
    ((++FAIL_COUNT))
fi

# ============================================================
# Test: plan_validator accepts INSTALL_FLATPAK
# ============================================================
plan_reset
plan_add "$(plan_record_create INSTALL_FLATPAK "org.mozilla.firefox")"
if plan_validate; then
    echo "[PASS] plan_validator accepts INSTALL_FLATPAK"
    ((++PASS_COUNT))
else
    echo "[FAIL] plan_validator rejects INSTALL_FLATPAK" >&2
    ((++FAIL_COUNT))
fi

# ============================================================
# Test: TOML parser handles [packages] flatpak
# ============================================================
toml_file="$(mktemp --suffix=.toml)"
printf '%s\n' '[packages]' > "$toml_file"
printf '%s\n' 'required = ["hyprland", "kitty"]' >> "$toml_file"
printf '%s\n' 'aur = ["hyprpanel-git"]' >> "$toml_file"
printf '%s\n' 'flatpak = ["org.mozilla.firefox", "org.keepassxc.KeePassXC"]' >> "$toml_file"
config_read "$toml_file"
config_toml_to_legacy

if [[ "${FLATPAK_PACKAGES:-}" == "org.mozilla.firefox org.keepassxc.KeePassXC" ]]; then
    echo "[PASS] TOML flatpak = 2 packages"
    ((++PASS_COUNT))
else
    echo "[FAIL] TOML FLATPAK_PACKAGES: '${FLATPAK_PACKAGES:-}'" >&2
    ((++FAIL_COUNT))
fi

rm -f "$toml_file"

# ============================================================
# Summary
# ============================================================
print_summary
