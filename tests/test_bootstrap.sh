#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/bootstrap.sh"
source "$PROJECT_ROOT/services/bootstrap.sh"
source "$PROJECT_ROOT/modules/bootstrap.sh"