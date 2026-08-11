#!/usr/bin/env bash
# Build a .deb package for HCC.
# Usage: bash scripts/package-deb.sh [out_dir]
# Requires: dpkg-deb (Debian/Ubuntu CI runner or local).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$SCRIPT_DIR/VERSION")"
OUT_DIR="${1:-$SCRIPT_DIR/dist/deb}"
STAGE="$(mktemp -d)"

trap 'rm -rf "$STAGE"' EXIT

bash "$SCRIPT_DIR/scripts/build-staging.sh" "$STAGE"

mkdir -p "$STAGE/DEBIAN"
cat > "$STAGE/DEBIAN/control" << EOF
Package: hcc
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Depends: bash, git, curl, sudo
Recommends: python3
Maintainer: Hyprland Control Center <https://github.com/laosifu/Hyprland-Control-Center>
Description: Hyprland Control Center - Install and manage Hyprland desktops
 Run 'hcc' to open the interactive menu, 'hcc doctor' to check your system.
 For login screen integration: 'sudo hcc session setup-login'.
EOF

mkdir -p "$OUT_DIR"
dpkg-deb --build --root-owner-group "$STAGE" "$OUT_DIR/hcc_${VERSION}_all.deb" >/dev/null
echo "Built: $OUT_DIR/hcc_${VERSION}_all.deb"
