#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

desktop_package_load mailong2401

[[ "$PACKAGE_ROOT" == "desktop-packages/mailong2401/payload" ]]
[[ -d "$PROJECT_ROOT/$PACKAGE_ROOT/.config" ]]
[[ -d "$PROJECT_ROOT/$PACKAGE_ROOT/Pictures" ]]

desktop_generate_plan

expected_source="$PROJECT_ROOT/desktop-packages/mailong2401/payload/.config"

printf '%s\n' "${PLAN_ACTIONS[@]}" | grep -Fqx "COPY_DIRECTORY|$expected_source|$HOME"

if printf '%s\n' "${PLAN_ACTIONS[@]}" | grep -Fq 'analysis/'; then
    echo "Desktop plan must not use analysis as an installation source." >&2
    exit 1
fi

PACKAGE_ROOT="analysis/mailong2401/dotfiles-hyprland"

if desktop_package_validate mailong2401 >/dev/null 2>&1; then
    echo "Desktop package validation accepted an analysis workspace." >&2
    exit 1
fi

echo "[PASS] desktop package payload is self-contained"
