# Hyprland Control Center (HCC) - Project State

*Last updated: 2026-07-23*

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

Desktop Registry

✅ Complete (v0.4.0)

URL Install

✅ Complete (v0.4.0)

External Manifest

✅ Defined (v0.4.0)

Conflict Detection

✅ Complete (v0.4.0)

Profile Switch

✅ Complete (v0.5.0 — config restore, session capture, TUI switching, DM login entries)

Session Manager

✅ Complete (v0.5.0 — register/capture/restore, interactive TUI, DM integration)

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

External Package Install + Manifest Standardization

Goal:

Allow installing desktop packages from any GitHub URL, with a standardized
manifest format (hcc.manifest + package.conf).

Status:

URL install implemented. Local directory install implemented. Manifest format
defined. Bundled packages remain for convenience; will be removed at v1.0.0.

---

# 11. Next Planned Milestones

## Short-term (v0.5.0)

1. **Full profile switching** — auto-restore config files when switching profiles
   - Per-profile snapshots (backup deployed files at install time)
   - Switch = backup current + restore target + handle git repos
2. `hcc desktop uninstall` — remove a desktop and rollback
3. External package discovery (search/community registry)

## Medium-term (v0.6.0–v0.9.0)

4. Dependency Layer redesign
5. Deployment Service extraction
6. Action Engine
7. Plugin Runtime
8. Inventory Engine
9. Resume Generator

## v1.0.0

10. **Remove bundled packages** from HCC repo

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

---

# 15. Desktop Registry + URL Install — v0.4.0 (2026-07-23)

HCC now has a central desktop registry that discovers, validates, and lists
available desktop packages. The registry lives in `desktops/` and is separate
from both the `analysis/` research workspace and the legacy `desktop-packages/`
directory.

Desktop packages can now be installed directly from GitHub URLs or any local
directory containing a valid `package.conf`. This is the foundation for the
future unbundled architecture where packages live in their own repositories.

### New directory structure:

```
desktops/
├── registry.conf          ← Central registry (single source of truth)
├── mailong2401/
│   ├── package.conf       ← Desktop Package Manifest (new format)
│   └── hooks/
└── end-4/
    ├── package.conf
    └── hooks/
```

### New components:

| Component | Path | Purpose |
|---|---|---|
| Registry loader | `lib/desktop_registry.sh` | Read/walk/validate registry entries |
| Desktop renderer | `lib/renderers/desktop_renderer.sh` | UI for `hcc desktop list` |
| Desktop list module | `modules/desktop_list.sh` | `hcc desktop list` workflow |
| Package manifests | `desktops/*/package.conf` | Standardized desktop package metadata |

### Key behaviours:

* `hcc desktop` or `hcc desktop list` — lists all registered desktops
* `hcc desktop install <name>` — tries `desktops/<name>/package.conf` first,
  falls back to `desktop-packages/<name>/desktop.conf`
* Registry supports IDs with hyphens (e.g. `end-4` → `END_4`)
* Empty `COPY_ITEMS` does not break the planner

### Desktop packages available:

1. **Mailong2401 Desktop** (mailong2401) — full desktop with Hyprland,
   Quickshell, Kitty, Fish, and cartoon-shell
2. **end-4 illogical-impulse** (end-4) — 76 PACMAN + 10 AUR packages,
   Quickshell widget system, AI integration, Material Design theming

### New components (this release):

| Component | Path | Purpose |
|---|---|---|
| Conflict detection | `lib/plan_conflict.sh` | Warns before overwriting existing files/repos |
| Profile switch | `modules/profile_switch.sh` | Changes active profile marker |
| Onboarding | `README.md`, `install.sh` | Hướng dẫn tiếng Việt, cài đặt 1 lệnh |
| Help text | `lib/utils.sh` | `hcc help` tiếng Việt có ví dụ |

### Verification:

* Unit suite passes (18 tests)
* CLI smoke suite passes (10 commands)
* `hcc desktop list` shows both packages
* `hcc desktop install <name>` previews correctly from both registry and legacy paths
* `hcc desktop install <url>` clones external repos, validates hcc.manifest + package.conf
* `hcc desktop install <dir>` loads directly from any local directory with package.conf
* Conflict detection warns before overwriting existing files/repos
* `hcc profile switch <id>` changes the active profile marker (config restore is manual)

### External manifest format:

External desktop package repos must contain:

```
repo/
├── hcc.manifest          ← Metadata for discovery/validation
│   HCC_MANIFEST_VERSION=1
│   ID=my-desktop
│   NAME="My Desktop"
│   TYPE=desktop-profile
│   AUTHOR="..."
└── package.conf          ← Package definition (same format as desktops/*/package.conf)
    PACMAN_PACKAGES="..."
    AUR_PACKAGES="..."
    GIT_REPOSITORIES="..."
    COPY_ITEMS="..."
```

The copy planner resolves `PACKAGE_ROOT` relative to the cloned repo directory
(when `PACKAGE_ROOT_DIR` is set) or to `$PROJECT_ROOT` (for bundled packages).

### Future: unbundled desktop packages

The `desktops/` directory currently bundles popular desktop packages for
convenience. When HCC reaches v1.0.0, bundled packages will be removed.
Users will install desktop packages exclusively via URL:

    hcc desktop install https://github.com/<author>/<dotfiles-repo>

The framework (`bin/hcc`, `lib/`, `services/`, `modules/`, `operations/`)
will remain in the HCC repository. Desktop packages will live in their own
repositories.

---

# 16. Session-Based Profile Switching — Resolved

> Chuyển đổi desktop được xử lý qua Session Manager (section 17) thay vì
> profile switching cũ. Mỗi desktop là một session độc lập, switching chỉ
> thay symlink — không cần backup/restore snapshot.

## Current approach

| Feature | Status |
|---|---|
| `hcc session switch` | ✅ TUI chọn session, tự động deploy/undeploy symlink |
| `session_deploy / session_undeploy` | ✅ Chỉ thay symlink, không move file |
| `session_setup_login_entry` | ✅ Tự động tạo login entry nếu có quyền root |
| `hcc session setup-login` | ✅ Tạo login entries cho tất cả session |

## Kiến trúc

Khi install: file config được copy thẳng vào `~/.config/hcc/sessions/<id>/root/`
(không qua $HOME). Sau đó `session_deploy` tạo symlink:
`$HOME/.config/hypr → sessions/<id>/root/.config/hypr`

Khi switch: undeploy symlink cũ → deploy symlink mới. File gốc trong session
root không bị ảnh hưởng.

---

# 17. Session Manager — v0.5.0 (2026-07-23)

> **Update v0.5.1:** Install flow được tự động hoá hoàn toàn. Khi cài desktop,
> file config được copy thẳng vào session root, không qua $HOME. Symlink được
> tạo tự động. Login entry được tạo nếu có quyền root.

## Kiến trúc hiện tại

```
hcc desktop install <name>
  ↓
desktop_pipeline_execute()
  ↓ session_register()           ← Tạo session trước
  ↓ SESSION_INSTALL_ID set       ← Dispatcher redirect dest đến session root
  ↓ deployment_service_execute_plan
    ├── COPY_DIRECTORY → ~/.config/hcc/sessions/<id>/root/.config/
    ├── CLONE_REPOSITORY → ~/.config/hcc/sessions/<id>/root/<repo>/
    ├── INSTALL_PACKAGE → hệ thống (không đổi)
    └── INSTALL_AUR → hệ thống (không đổi)
  ↓ unset SESSION_INSTALL_ID
  ↓
desktop_pipeline_finalize()
  ↓ session_build_manifest_from_plan()   ← Đọc PLAN_ACTIONS
  ↓ session_deploy()                     ← Tạo symlink: $HOME → session/root
  ↓ session_setup_login_entry()          ← Tạo .desktop nếu có quyền
```

## Session isolation (symlink-based)

File config không bao giờ được ghi vào $HOME trực tiếp. Mỗi desktop có thư
mục riêng, hoàn toàn độc lập:

```
~/.config/hcc/sessions/
├── mailong2401/
│   ├── session.conf
│   ├── manifest              ← Danh sách relative paths đã deploy
│   └── root/
│       ├── .config/hypr/
│       ├── .config/kitty/
│       └── ...
├── end-4/
│   ├── session.conf
│   ├── manifest
│   └── root/ ...
└── session-active

$HOME/.config/hypr  →  sessions/mailong2401/root/.config/hypr  (symlink)
$HOME/.config/kitty →  sessions/mailong2401/root/.config/kitty (symlink)
```

## Switching

```bash
hcc session switch  # TUI → undeploy symlink cũ + deploy symlink mới
```

Không cần move/copy file. Chỉ thay symlink. Dữ liệu session cũ vẫn nguyên.

## Login screen

Tự động tạo `/usr/share/wayland-sessions/hcc-<id>.desktop` nếu có quyền root.
Nếu không, user chạy: `sudo hcc session setup-login`

## Components

| Component | Path | Purpose |
|---|---|---|
| Session library | `lib/session.sh` | Core: register, deploy, undeploy, switch, manifest, login entry |
| Session command | `lib/commands/session_command.sh` | `hcc session <subcommand>` dispatcher |
| Session TUI | `modules/session_command.sh` | Interactive menu (`hcc session switch`) |
| Session launcher | `lib/launchers/session-launcher.sh` | Wayland entry point for DM |
| Pipeline | `lib/desktop_pipeline.sh` | Orchestrates register → execute → deploy |
| Action dispatcher | `lib/action_dispatcher.sh` | Redirects COPY_DIRECTORY/CLONE_REPOSITORY to session root |

## Verification

* All unit tests pass (18 tests).
* Session register/deploy/undeploy/switch verified.
* `hcc session list` shows registered sessions.
* Login entries created via `hcc session setup-login` or auto if root.

## Next steps

- Add Hyprland reload after session switch for in-session config refresh.
- External package discovery (search/community registry).
