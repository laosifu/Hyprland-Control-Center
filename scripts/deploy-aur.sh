#!/usr/bin/env bash
# Deploy HCC to AUR
# Usage: bash scripts/deploy-aur.sh <hcc-bin|hcc-git|all>
#
# Prerequisites:
#   1. AUR account: https://aur.archlinux.org/register/
#   2. SSH key added: https://aur.archlinux.org/account/
#   3. SSH key loaded: ssh-add ~/.ssh/id_rsa
#
# Steps:
#   This script clones the AUR repo, copies files, generates .SRCINFO,
#   and shows the final git push command. You run the push yourself.

set -euo pipefail

PKG="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "$PKG" == "all" || "$PKG" == "hcc-bin" ]]; then
    echo "=== Preparing hcc-bin ==="
    WORK_DIR="/tmp/hcc-aur-hcc-bin"
    rm -rf "$WORK_DIR"
    git clone ssh://aur@aur.archlinux.org/hcc-bin.git "$WORK_DIR"
    cp "$SCRIPT_DIR/dist/aur/hcc-bin/PKGBUILD" "$WORK_DIR/"
    cp "$SCRIPT_DIR/dist/aur/hcc-bin/hcc.install" "$WORK_DIR/"
    cd "$WORK_DIR"
    updpkgsums 2>/dev/null || true
    makepkg --printsrcinfo > .SRCINFO
    echo
    echo "=== hcc-bin ready ==="
    echo "Review and push:"
    echo "  cd $WORK_DIR"
    echo "  git diff"
    echo "  git add PKGBUILD hcc.install .SRCINFO"
    echo "  git commit -m 'hcc-bin v$(cat "$SCRIPT_DIR/VERSION")'"
    echo "  git push"
    echo
fi

if [[ "$PKG" == "all" || "$PKG" == "hcc-git" ]]; then
    echo "=== Preparing hcc-git ==="
    WORK_DIR="/tmp/hcc-aur-hcc-git"
    rm -rf "$WORK_DIR"
    git clone ssh://aur@aur.archlinux.org/hcc-git.git "$WORK_DIR"
    cp "$SCRIPT_DIR/dist/aur/hcc-git/PKGBUILD" "$WORK_DIR/"
    cp "$SCRIPT_DIR/dist/aur/hcc-git/hcc.install" "$WORK_DIR/"
    cd "$WORK_DIR"
    makepkg --printsrcinfo > .SRCINFO
    echo
    echo "=== hcc-git ready ==="
    echo "Review and push:"
    echo "  cd $WORK_DIR"
    echo "  git diff"
    echo "  echo PKGBUILD hcc.install .SRCINFO > .gitignore"
    echo "  git add PKGBUILD hcc.install .SRCINFO"
    echo "  git commit -m 'hcc-git v$(cat "$SCRIPT_DIR/VERSION")'"
    echo "  git push"
    echo
fi

echo "=== Done ==="
echo "After pushing, verify:"
echo "  yay -S hcc-bin"
echo "  hcc --version"
