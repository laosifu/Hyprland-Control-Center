#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

plan_reset

plan_install_package kitty
plan_install_aur cava

echo "Plan size: $(plan_size)"

plan_render