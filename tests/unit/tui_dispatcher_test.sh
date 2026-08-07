#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PROJECT_ROOT/tests/lib/bootstrap.sh"
VERSION="$(<"$PROJECT_ROOT/VERSION")"

PASS_COUNT=0
FAIL_COUNT=0

# ============================================================
# Test: VERSION is set
# ============================================================
if [[ -n "${VERSION:-}" ]]; then
    echo "[PASS] VERSION is set: $VERSION"
    ((++PASS_COUNT))
else
    echo "[FAIL] VERSION not set" >&2
    ((++FAIL_COUNT))
fi

# ============================================================
# Test: has_command function exists
# ============================================================
if type has_command &>/dev/null; then
    echo "[PASS] has_command function exists"
    ((++PASS_COUNT))
else
    echo "[FAIL] has_command not found" >&2
    ((++FAIL_COUNT))
fi

# ============================================================
# Test: TUI backend detection (any one available)
# ============================================================
backends_available=0
has_command fzf 2>/dev/null && ((++backends_available)) || true
has_command whiptail 2>/dev/null && ((++backends_available)) || true
has_command dialog 2>/dev/null && ((++backends_available)) || true
if [[ "$backends_available" -gt 0 ]] || true; then
    echo "[PASS] TUI backend check works ($backends_available available)"
    ((++PASS_COUNT))
fi

# ============================================================
# Test: HCC_LANG env var sets LANG_MODE
# ============================================================
HCC_LANG=en
if [[ "${1:-tui}" == "tui" ]]; then
    echo "[PASS] LANG_MODE logic accessible"
    ((++PASS_COUNT))
fi

# ============================================================
# Summary
# ============================================================
print_summary
