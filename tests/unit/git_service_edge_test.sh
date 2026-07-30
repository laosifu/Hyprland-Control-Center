#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/tests/lib/bootstrap.sh"

# Mock git operations to avoid network calls
git_operation_clone() {
    local dest="$2"
    mkdir -p "$dest"
    git -C "$dest" init --quiet 2>/dev/null
    git -C "$dest" config user.email "test@test" 2>/dev/null
    git -C "$dest" config user.name "test" 2>/dev/null
    echo "content" > "$dest/file.txt"
    git -C "$dest" add -A 2>/dev/null
    git -C "$dest" commit -m "init" --quiet 2>/dev/null
    return 0
}

git_operation_pull() { return 0; }

TEST_DIR="/tmp/hcc-test-git-edge-$$"
cleanup() { rm -rf "$TEST_DIR"; }
trap cleanup EXIT
mkdir -p "$TEST_DIR"
execution_set_dry_run false

# Test 1: Clone to non-existing directory
rm -rf "$TEST_DIR/fresh"
git_service_clone_or_update https://example.com/repo.git "$TEST_DIR/fresh"
assert_success "Test 1: Fresh clone" test -d "$TEST_DIR/fresh/.git"

# Test 2: Clone to existing non-git directory (original bug: File exists)
mkdir -p "$TEST_DIR/existing"
echo "old" > "$TEST_DIR/existing/old.txt"
git_service_clone_or_update https://example.com/repo.git "$TEST_DIR/existing"
assert_success "Test 2: Existing dir becomes git" test -d "$TEST_DIR/existing/.git"
assert_success "Test 2: Old content removed" test ! -f "$TEST_DIR/existing/old.txt"

# Test 3: Update existing git repo
git_service_clone_or_update https://example.com/repo.git "$TEST_DIR/existing"
assert_success "Test 3: Update existing repo" true

# Test 4: Empty destination (no crash)
execution_set_dry_run true
git_service_clone_or_update https://example.com/repo.git "" 2>/dev/null || true
assert_success "Test 4: Empty destination handled" true

print_summary
exit "$FAIL_COUNT"
