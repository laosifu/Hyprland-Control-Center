# Hyprland Control Center (HCC) - Project State

*Last updated: 2026-07-17*

---

# 1. Project Overview

Hyprland Control Center (HCC) is a Bash-based deployment framework for installing and managing desktop environments, plugins, themes, and system configuration.

The project focuses on:

* deterministic installation
* rollback support
* reusable services
* modular architecture
* plugin-driven expansion
* desktop package management

---

# 2. Team Roles

## Technical Lead

ChatGPT

Responsibilities:

* architecture
* code review
* refactoring decisions
* roadmap
* consistency
* technical debt

Never writes code without understanding the current architecture.

---

## Implementer / Tester

Human

Responsibilities:

* implement code
* execute commands
* run tests
* provide outputs
* verify behavior

Never changes architecture decisions.

---

# 3. Development Principles

Always follow:

Read

↓

Understand

↓

Design

↓

Implement

↓

Test

↓

Log

↓

Continue

Never skip layers.

Never refactor blindly.

Desktop installation must remain functional during refactoring.

---

# 4. Architecture

CLI

↓

Module

↓

Planner

↓

Action DSL

↓

Executor

↓

Dispatcher

↓

Services

↓

Operations

↓

Shell Commands

---

# 5. Current Repository Status

Core Bootstrap

✅ Complete

Planner

✅ Complete

Plan Record API

✅ Complete

Executor

✅ Complete

Desktop Installation

✅ Complete

Filesystem Service

✅ Complete

Rollback

✅ Complete

Backup

✅ Complete

Testing Framework

✅ Stable

---

# 6. Existing Service Layer

Current services:

* action_service
* aur_service
* backup_service
* dependency_service
* deployment_service (placeholder)
* desktop_service
* filesystem_service
* git_service
* hook_service
* package_service

---

# 7. Existing Bootstrap

Bootstrap has already been modularized.

Current layout:

lib/bootstrap/

* core.sh
* common.sh
* runtime.sh
* manifest.sh
* planning.sh
* desktop.sh
* backup.sh
* renderers.sh
* commands.sh
* queries.sh

Root bootstrap simply loads these modules.

---

# 8. Testing Status

Current tests:

* bootstrap
* planner
* executor
* filesystem
* package
* git
* transaction
* backup
* desktop prepare

All tests currently pass.

---

# 9. Technical Debt

Action Engine

Status:

Stub

Reason:

Currently prints action payload only.

Will become real dispatcher later.

---

Deployment Service

Status:

Placeholder

Reason:

Deployment pipeline currently exists inside desktop pipeline.

Will be extracted later.

---

Dependency Service

Needs redesign.

Current implementation performs installation rather than dependency management.

Keep unchanged until Manifest Engine is finished.

---

# 10. Current Milestone

Manifest Engine

Goal:

Centralize all manifest loading.

Future consumers:

* Planner
* UI
* Resume
* Inventory
* Deployment
* Plugin Runtime

---

# 11. Next Planned Milestones

1. Manifest Engine
2. Dependency Layer redesign
3. Deployment Service
4. Action Engine
5. Plugin Runtime
6. Inventory Engine
7. Resume Generator

---

# 12. Rules For Future Sessions

Always read PROJECT_STATE.md first.

Never redesign architecture without auditing current code.

Prefer completing existing abstractions over creating new ones.

Do not replace working pipelines.

Refactor incrementally.

Every architectural decision must preserve Desktop Install functionality.
Manifest terminology

Current implementation:

Backup Manifest

Purpose:

Store metadata for backups.

Status:

Stable.

Do not reuse for desktop package manifests.

Desktop package manifests will be implemented separately in a future milestone.

---

# 13. Release Update — v0.2.0 (2026-07-22)

Completed in this release:

* Desktop package payloads are self-contained under `desktop-packages/`; the
  `analysis/` workspace is research-only.
* Desktop package metadata, payload locations and copy items are validated
  before a plan can execute.
* Desktop installation now checks supported distributions and supports optional
  `pre-install.sh` and `post-install.sh` hooks.
* Deployment and Action Engine APIs execute the real validated plan rather than
  acting as placeholders.
* Backup creates an isolated timestamped snapshot with a backup manifest;
  restore can list snapshots or restore a selected snapshot after confirmation.
* Themes and plugins support install and uninstall commands.
* CLI help and integration coverage reflect the available commands.

Verification:

* Unit suite passes.
* CLI smoke suite passes (8 commands).
* Backup-and-restore was verified in an isolated temporary home directory.

---

# 14. Profile Registry Foundation — v0.3.0 (2026-07-22)

HCC now records every successful desktop installation as a local desktop
profile. Profile state contains package metadata, origin, the pre-install
snapshot and a deployment ownership plan. The active profile is explicit,
rather than inferred from files in `$HOME`.

Current user commands:

* `hcc profile list`
* `hcc profile status`

The registry is the prerequisite for safe switching, updates and rollback.
Repository URL installation remains intentionally pending until a trusted
manifest format and explicit preview policy are implemented; HCC must never
execute arbitrary installer scripts from an untrusted link.
