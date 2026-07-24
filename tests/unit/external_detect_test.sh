#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

TESTDIR="$(mktemp -d)"
trap 'rm -rf "$TESTDIR"' EXIT

# ============================================================
# Test: desktop_external_known_packages
# ============================================================
pkgs="$(desktop_external_known_packages "hypr")"
assert_equals "known: hypr → hyprland" "hyprland" "$pkgs"

pkgs="$(desktop_external_known_packages "kitty")"
assert_equals "known: kitty → kitty" "kitty" "$pkgs"

pkgs="$(desktop_external_known_packages "nonexistent")"
assert_equals "known: nonexistent → empty" "" "$pkgs"

# ============================================================
# Test: desktop_external_detect_packages
# ============================================================
mkdir -p "$TESTDIR/repo/.config/kitty" "$TESTDIR/repo/.config/waybar" "$TESTDIR/repo/hypr"
mapfile -t detected < <(desktop_external_detect_packages "$TESTDIR/repo")
assert_equals "detect: kitty" "kitty" "$(echo "${detected[0]}" | tr ' ' '\n' | grep kitty || true)"
assert_equals "detect: waybar" "waybar" "$(echo "${detected[0]}" | tr ' ' '\n' | grep waybar || true)"
assert_equals "detect: hyprland" "hyprland" "$(echo "${detected[0]}" | tr ' ' '\n' | grep hyprland || true)"

# ============================================================
# Test: desktop_external_detect_from_scripts
# ============================================================

# Test 3a: no scripts → empty
mapfile -t lines < <(desktop_external_detect_from_scripts "$TESTDIR/empty")
assert_equals "no scripts: pacman empty" "" "${lines[0]}"
assert_equals "no scripts: aur empty" "" "${lines[1]}"

# Test 3b: script with pacman -S
mkdir -p "$TESTDIR/script-pacman"
cat > "$TESTDIR/script-pacman/install.sh" << 'SCRIPT'
#!/bin/bash
sudo pacman -S hyprland kitty waybar
yay -S cava-git hyprpanel-git
SCRIPT
mapfile -t lines < <(desktop_external_detect_from_scripts "$TESTDIR/script-pacman")
assert_equals "script pacman: found hyprland" "hyprland kitty waybar" "$(echo "${lines[0]}")"
assert_equals "script pacman: found aur" "cava-git hyprpanel-git" "$(echo "${lines[1]}")"

# Test 3c: script with paru (paru is AUR helper, detected as AUR)
mkdir -p "$TESTDIR/script-paru"
cat > "$TESTDIR/script-paru/setup.sh" << 'SCRIPT'
#!/bin/bash
paru -S swww swaylock-effects-git
SCRIPT
mapfile -t lines < <(desktop_external_detect_from_scripts "$TESTDIR/script-paru")
assert_equals "script paru: no pacman" "" "$(echo "${lines[0]}")"
assert_equals "script paru: found aur" "swaylock-effects-git swww" "$(echo "${lines[1]}")"

# Test 3d: script with --flags and comments
mkdir -p "$TESTDIR/script-flags"
cat > "$TESTDIR/script-flags/install.sh" << 'SCRIPT'
sudo pacman -S --needed --noconfirm hyprland waybar
# yay -S some-aur-package
SCRIPT
mapfile -t lines < <(desktop_external_detect_from_scripts "$TESTDIR/script-flags")
assert_equals "script flags: no flags in packages" "hyprland waybar" "$(echo "${lines[0]}")"
assert_equals "script flags: commented aur ignored" "" "$(echo "${lines[1]}")"

# Test 3e: script with duplicate packages
mkdir -p "$TESTDIR/script-dupes"
cat > "$TESTDIR/script-dupes/install.sh" << 'SCRIPT'
pacman -S kitty rofi
pacman -S kitty waybar
SCRIPT
mapfile -t lines < <(desktop_external_detect_from_scripts "$TESTDIR/script-dupes")
assert_equals "script dupes: kitty appears once" "kitty rofi waybar" "$(echo "${lines[0]}")"

# ============================================================
# Test: desktop_external_generate_package_conf (auto mode)
# ============================================================

# Test 4a: repo with known config dirs
mkdir -p "$TESTDIR/good/.config/hypr" "$TESTDIR/good/.config/kitty"
desktop_external_generate_package_conf "$TESTDIR/good" "test-desktop" "Test Desktop" "https://github.com/user/test" "auto" || true
assert_success "generate: auto mode succeeds with known dirs" test -f "$TESTDIR/good/package.conf"
source "$TESTDIR/good/package.conf" 2>/dev/null || true
assert_equals "generate: ID matches" "test-desktop" "$ID"
rm -f "$TESTDIR/good/package.conf"

# Test 4b: empty repo returns 1 in auto mode
mkdir -p "$TESTDIR/empty-repo"
if desktop_external_generate_package_conf "$TESTDIR/empty-repo" "empty" "Empty" "https://github.com/user/empty" "auto"; then
    echo "[FAIL] auto mode should return 1 for empty repo" >&2; ((++FAIL_COUNT))
else
    echo "[PASS] auto mode returns 1 for empty repo"; ((++PASS_COUNT))
fi

# ============================================================
# Test: desktop_external_detect_git_repos
# ============================================================
mkdir -p "$TESTDIR/gitrepo"
assert_equals "no git: empty" "" "$(desktop_external_detect_git_repos "$TESTDIR/gitrepo")"

mkdir -p "$TESTDIR/gitrepo/external"
git -C "$TESTDIR/gitrepo/external" init -q 2>/dev/null || true
git -C "$TESTDIR/gitrepo/external" remote add origin https://github.com/user/test-repo 2>/dev/null || true
result="$(desktop_external_detect_git_repos "$TESTDIR/gitrepo")"
assert_equals "git subdir: found with remote" "true" "$(echo "$result" | grep -q 'test-repo' && echo true || echo false)"

# ============================================================
# Test: desktop_external_detect_copy_items
# ============================================================
mkdir -p "$TESTDIR/items/.config/hypr" "$TESTDIR/items/.config/kitty" "$TESTDIR/items/Pictures"
result="$(desktop_external_detect_copy_items "$TESTDIR/items")"
assert_equals "copy items: includes hypr" "true" "$(echo "$result" | grep -q '.config/hypr' && echo true || echo false)"
assert_equals "copy items: includes kitty" "true" "$(echo "$result" | grep -q '.config/kitty' && echo true || echo false)"

# ============================================================
# Test: desktop_external_detect_from_home_config
# ============================================================
# Use a mock HOME
OLD_HOME="$HOME"
export HOME="$TESTDIR/home"
mkdir -p "$HOME/.config/hypr" "$HOME/.config/kitty"
mapfile -t home_lines < <(desktop_external_detect_from_home_config || true)
assert_equals "home detect: hyprland found" "true" "$(echo "${home_lines[0]}" | grep -q 'hyprland' && echo true || echo false)"
assert_equals "home detect: kitty found" "true" "$(echo "${home_lines[0]}" | grep -q 'kitty' && echo true || echo false)"
assert_equals "home detect: config dirs" "true" "$(echo "${home_lines[2]}" | grep -q 'hypr' && echo true || echo false)"
HOME="$OLD_HOME"

# ============================================================
# Test: desktop_external_import_home_to_session
# ============================================================
export HOME="$TESTDIR/home2"
mkdir -p "$HOME/.config/hypr" "$HOME/.config/kitty"
echo "test config" > "$HOME/.config/hypr/hyprland.conf"

SESSION_BASE="$TESTDIR/sessions"
mkdir -p "$SESSION_BASE/test-session/root"

# Mock session_root
session_root() { echo "$SESSION_BASE/$1/root"; }

desktop_external_import_home_to_session "test-session" "hypr kitty"

assert_success "import: hypr moved to session" test -f "$SESSION_BASE/test-session/root/.config/hypr/hyprland.conf"
assert_success "import: symlink created" test -L "$HOME/.config/hypr"
HOME="$OLD_HOME"

# ============================================================
# Test: desktop_external_show_package_conf_help (just verify no crash)
# ============================================================
desktop_external_show_package_conf_help > /dev/null 2>&1
assert_success "help: runs without error" true

# ============================================================
print_summary
