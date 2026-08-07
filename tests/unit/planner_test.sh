#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

#test_header "Planner"

plan_reset

plan_add "INSTALL_PACKAGE|kitty|"

plan_add "INSTALL_AUR|cava|"

echo "Plan size: $(plan_size)"

plan_render