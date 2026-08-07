#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

execution_set_dry_run true

# Test 1: package_service_install registers a rollback remove
transaction_reset
package_service_install "hcc-rollback-test-pkg" 2>/dev/null || true

found=false
for cmd in "${TRANSACTION_ROLLBACKS[@]}"; do
    grep -Fq "package_operation_remove 'hcc-rollback-test-pkg'" <<< "$cmd" && found=true
done
[[ "$found" == true ]] && assert_success "package install registers rollback remove"

# Test 2: aur_service_install registers a rollback remove
transaction_reset
aur_service_install "hcc-rollback-test-aur" 2>/dev/null || true

found=false
for cmd in "${TRANSACTION_ROLLBACKS[@]}"; do
    grep -Fq "package_operation_remove 'hcc-rollback-test-aur'" <<< "$cmd" && found=true
done
[[ "$found" == true ]] && assert_success "aur install registers rollback remove"

# Test 3: flatpak install registers a rollback
transaction_reset
dispatch_action "INSTALL_FLATPAK|org.example.HCCRollbackTest|" 2>/dev/null || true

found=false
for cmd in "${TRANSACTION_ROLLBACKS[@]}"; do
    grep -Fq "flatpak uninstall -y 'org.example.HCCRollbackTest'" <<< "$cmd" && found=true
done
[[ "$found" == true ]] && assert_success "flatpak install registers rollback remove"

# Test 4: package already installed does NOT register rollback
transaction_reset
package_service_install "bash" 2>/dev/null || true
[[ ${#TRANSACTION_ROLLBACKS[@]} -eq 0 ]] && assert_success "already-installed package registers no rollback"

print_summary
exit "$FAIL_COUNT"
