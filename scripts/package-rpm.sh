#!/usr/bin/env bash
# Build a .rpm package for HCC.
# Usage: bash scripts/package-rpm.sh [out_dir]
# Requires: rpmbuild (Fedora CI runner or local with rpm-build installed).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$SCRIPT_DIR/VERSION")"
OUT_DIR="${1:-$SCRIPT_DIR/dist/rpm}"
STAGE="$(mktemp -d)"
RPMBUILD_DIR="$(mktemp -d)"

trap 'rm -rf "$STAGE" "$RPMBUILD_DIR"' EXIT

command -v rpmbuild >/dev/null 2>&1 || {
    echo "ERROR: rpmbuild not found. Install rpm-build (Fedora) or rpm (Debian/Ubuntu)." >&2
    exit 1
}

bash "$SCRIPT_DIR/scripts/build-staging.sh" "$STAGE"

mkdir -p "$RPMBUILD_DIR/SOURCES"
tar -C "$STAGE" -czf "$RPMBUILD_DIR/SOURCES/hcc.tar.gz" .

cat > "$RPMBUILD_DIR/hcc.spec" << EOF
Name:           hcc
Version:        $VERSION
Release:        1%{?dist}
Summary:        Hyprland Control Center - Install and manage Hyprland desktops
License:        GPL-3.0-only
URL:            https://github.com/laosifu/Hyprland-Control-Center
BuildArch:      noarch
Requires:       bash, git, curl, sudo

%description
Install and manage Hyprland desktops.
Run 'hcc' to open the interactive menu, 'hcc doctor' to check your system.
For login screen integration: 'sudo hcc session setup-login'.

%prep
%setup -c -T

%build

%install
tar -C "%{buildroot}" -xzf %{_sourcedir}/hcc.tar.gz

%files
/usr/bin/hcc
/usr/lib/hcc/session-launcher
/usr/share/hcc
/usr/share/bash-completion/completions/hcc

%post
echo "Hyprland Control Center (HCC) installed."
echo "Run 'hcc' to open the interactive menu."
echo "For login screen integration: sudo hcc session setup-login"

%postun
echo "HCC removed. Your desktop profiles in ~/.local/share/hcc/ are preserved."
EOF

mkdir -p "$OUT_DIR"
rpmbuild --define "_topdir $RPMBUILD_DIR" -bb "$RPMBUILD_DIR/hcc.spec" >/dev/null
find "$RPMBUILD_DIR/RPMS" -name '*.rpm' -exec cp {} "$OUT_DIR/" \;
echo "Built: $OUT_DIR/hcc-$VERSION-1.noarch.rpm"
