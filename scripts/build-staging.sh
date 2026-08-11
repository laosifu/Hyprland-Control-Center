#!/usr/bin/env bash
# Build a staging tree (same layout as the AUR hcc-bin PKGBUILD).
# Shared by scripts/package-deb.sh and scripts/package-rpm.sh.
# Usage: bash scripts/build-staging.sh <stage_dir>

set -euo pipefail

STAGE="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$SCRIPT_DIR/VERSION")"

rm -rf "$STAGE"
mkdir -p "$STAGE/usr/bin"
mkdir -p "$STAGE/usr/lib/hcc"
mkdir -p "$STAGE/usr/share/hcc"
mkdir -p "$STAGE/usr/share/bash-completion/completions"

# hcc entry point (PROJECT_ROOT detection via BASH_SOURCE path)
cat > "$STAGE/usr/bin/hcc" << 'HCC_EOF'
#!/usr/bin/env bash

set -euo pipefail

hcc_self="$(readlink -f "${BASH_SOURCE[0]}")"
if [[ "$(dirname "$hcc_self")" == "/usr/bin" ]]; then
    PROJECT_ROOT="/usr/share/hcc"
else
    PROJECT_ROOT="$(cd "$(dirname "$hcc_self")/.." && pwd)"
fi
unset hcc_self

if [[ "$(id -u)" -eq 0 && -n "${SUDO_USER:-}" ]]; then
    HCC_REAL_USER="$SUDO_USER"
    HCC_REAL_HOME="$(getent passwd "$SUDO_USER" 2>/dev/null | cut -d: -f6 || echo "/home/$SUDO_USER")"
    export HCC_REAL_USER HCC_REAL_HOME
fi

source "$PROJECT_ROOT/lib/bootstrap.sh"
source "$PROJECT_ROOT/services/bootstrap.sh"
source "$PROJECT_ROOT/modules/bootstrap.sh"
execution_set_command_context "$@"
source "$PROJECT_ROOT/lib/dispatcher.sh"

load_config
log_info "Starting HCC..."
VERSION="$(<"$PROJECT_ROOT/VERSION")"
command_context_set "$@"
dispatch_command "$@"
HCC_EOF
chmod 755 "$STAGE/usr/bin/hcc"

install -Dm755 "$SCRIPT_DIR/lib/launchers/session-launcher.sh" \
    "$STAGE/usr/lib/hcc/session-launcher"

cp -a "$SCRIPT_DIR/desktops" "$STAGE/usr/share/hcc/desktops"
cp -a "$SCRIPT_DIR/lib" "$STAGE/usr/share/hcc/lib"
cp -a "$SCRIPT_DIR/services" "$STAGE/usr/share/hcc/services"
cp -a "$SCRIPT_DIR/operations" "$STAGE/usr/share/hcc/operations"
cp -a "$SCRIPT_DIR/modules" "$STAGE/usr/share/hcc/modules"
cp -a "$SCRIPT_DIR/plugins" "$STAGE/usr/share/hcc/plugins"
cp -a "$SCRIPT_DIR/themes" "$STAGE/usr/share/hcc/themes"
cp -a "$SCRIPT_DIR/handlers" "$STAGE/usr/share/hcc/handlers"
cp -a "$SCRIPT_DIR/VERSION" "$STAGE/usr/share/hcc/VERSION"
cp -a "$SCRIPT_DIR/docs" "$STAGE/usr/share/hcc/docs"
cp -a "$SCRIPT_DIR/config" "$STAGE/usr/share/hcc/config"
cp -a "$SCRIPT_DIR/completions" "$STAGE/usr/share/hcc/completions"

install -Dm644 "$SCRIPT_DIR/completions/hcc.bash" \
    "$STAGE/usr/share/bash-completion/completions/hcc"

# Fix LOG_DIR to use user-writable path
sed -i 's|LOG_DIR="\$PROJECT_ROOT/logs"|LOG_DIR="${HCC_LOG_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/hcc/logs}"|' \
    "$STAGE/usr/share/hcc/lib/logger.sh"

echo "Staging tree ready at: $STAGE (v$VERSION)"
