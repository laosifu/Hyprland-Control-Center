Hyprland Control Center (HCC)
Current Status

Architecture Version

v0.8

Current Phase

Foundation Complete — v0.6.1 in progress (uncommitted)

Architecture Refactor
Completed
CLI

✔ command parser

✔ doctor

✔ cleanup

✔ backup

✔ desktop install

Planner

✔ Action Model

✔ Plan Builder

✔ Plan Validator

✔ Renderer

Executor

✔ Execution Context

✔ Execution Policy

✔ Command Runner

✔ Operation Runner

✔ Dispatcher

✔ Transaction

✔ Rollback

Operations

Filesystem

Package

Git

AUR

Services

Filesystem

Package

Git

AUR

Backup

Desktop

Desktop

Desktop Planner

Desktop Pipeline

Desktop Prepare

Desktop Finalize

Desktop Backup

Desktop Install

Real installation works.

Backup

Automatic backup

Rollback support

Testing

Unit Tests

Integration Tests

Bootstrap Tests

Desktop Installation Tests

Everything passing.

Refactors Completed

Large bootstrap split.

lib/bootstrap/

introduced.

Tests unified.

Services separated from Operations.

Transaction system introduced.

Desktop Pipeline introduced.

Current Architecture
CLI

↓

Bootstrap

↓

Planner

↓

Executor

↓

Services

↓

Operations

↓

System
Current Bootstrap
core

common

runtime

manifest

planning

desktop

backup

renderers

commands

queries

Needs dependency cleanup.

Current Directory Count

Approximately

lib/

operations/

services/

tests/

analysis/

audit/

bin/

config/

Main code around

70–80 bash modules

Tests

20+
Next Tasks
Phase 1

Bootstrap dependency cleanup.

Phase 2

Split lib into

domain/

application/

infrastructure/

presentation/
Phase 3

Naming cleanup.

Phase 4

Plugin SDK.

Phase 5

Documentation generator.

Phase 6

Release v1.0.

Next Tasks (v0.6.1, uncommitted)
- Generic hcc.desktop login entry
- AI CLI commands (hcc ai setup/remove-key/status)
- Community registry search (hcc desktop search)
- Desktop uninstall: session + external dir cleanup
- 28 tests for external detect functions
- Bug fixes: session pipeline (5 bugs — see PROJECT_STATE.md section 20)

Verified
- All 19+ test suites pass
- All syntax checks pass (bash -n tất cả files)
- mailong2401 session rebuilt manually: payload copy, manifest, symlinks deploy OK
- session-active = mailong2401 (empty → fixed)
- session_deploy now handles files (not just directories)

Bug fixes applied
1. operations/filesystem_operation.sh — cp -a preserve directory structure
2. lib/action_dispatcher.sh — $HOME redirect bug (session_root//home/user)
3. lib/session.sh — session_deploy: -d → -e (handle files)
4. lib/session.sh — session_build_manifest_from_plan: scan source children
5. lib/desktop_pipeline.sh — auto-prompt sudo for login entries

Next session
1) bash tests/run_all.sh
2) bin/hcc help → kiểm tra CLI
3) hcc session switch → TUI menu
4) hcc ai status / hcc desktop search
5) Xem PROJECT_STATE.md section 19 + 20 để biết chi tiết

Coding Rules

No duplicated logic.

Services never call CLI.

Operations never know planner.

Planner never executes commands.

Only Executor executes commands.

Rollback registered before destructive operations.

Every public module has tests.

Every layer depends only downward.

My Role

Architecture owner.

Responsible for:

project structure
dependency graph
naming consistency
design decisions
long-term maintainability
Your Role

Implementation owner.

Responsible for:

applying patches
running tests
verifying runtime behavior
reporting results

No architectural decisions are required from you—we'll make those together based on the project's design.