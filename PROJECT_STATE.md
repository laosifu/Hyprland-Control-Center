# Hyprland Control Center (HCC) - Project State

*Last updated: 2026-07-25 (v0.8.0)*

---

# 1. Project Overview

Hyprland Control Center (HCC) is a Bash-based deployment framework for installing and managing Hyprland desktop environments.

The project focuses on:

* deterministic installation
* rollback support
* reusable services
* modular architecture
* plugin-driven expansion
* desktop package management
* distro-agnostic package abstraction

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

```
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
```

Core layers:

| Layer | Path | Purpose |
|---|---|---|
| Package abstraction | `lib/package/` | Detect, map, install, remove, query — 8 PMs + 4 AUR helpers |
| TOML config | `lib/config/read.sh` | Parse `package.toml` (Python + Bash), convert to legacy vars |
| Desktop registry | `lib/desktop_registry.sh` | Load/validate/list/search desktop packages |
| Planner | `lib/planners/` | Generate plan actions (package, aur, git, copy) |
| Executor | `lib/plan_executor.sh` | Execute plan with rollback, progress tracking |
| Services | `services/` | Service layer (package, aur, git, filesystem, backup, hook) |
| Operations | `operations/` | Atomic command wrappers |
| Session launcher | `lib/launchers/session-launcher.sh` | DM entry point, reads active profile, launches Hyprland |

---

# 5. Current Repository Status

| Component | Status |
|---|---|
| Core Bootstrap | ✅ Complete |
| Planner | ✅ Complete |
| Plan Record API | ✅ Complete |
| Executor | ✅ Complete |
| Desktop Installation | ✅ Complete |
| Filesystem Service | ✅ Complete |
| Rollback | ✅ Complete |
| Backup | ✅ Complete |
| Testing Framework | ✅ Stable |
| Desktop Registry | ✅ Complete (v0.4.0) |
| URL Install | ✅ Complete (v0.4.0) |
| External Manifest | ✅ Defined (v0.4.0) |
| Conflict Detection | ✅ Complete (v0.4.0) |
| Profile System | ✅ Complete (v0.5.0) |
| Session Launcher | ✅ Simplified (no isolation) |
| Package Abstraction Layer | ✅ Complete (Phase 1) |
| TOML Config Support | ✅ Complete (Phase 1) |
| AI Integration (Gemini) | ✅ Complete (v0.6.0) |
| AI CLI (`hcc ai`) | ✅ Complete (v0.6.1) |
| Community Registry Search | ✅ Complete (v0.6.1) |
| Flatpak Support | ✅ Complete (v0.7.0) |
| Display Manager Abstraction | ✅ Complete (v0.7.0) |
| `hcc desktop update` | ✅ Complete (v0.7.0) |
| `hcc desktop init` (wizard) | ✅ Complete (v0.7.0) |
| Batch Install (`pm_install_all`) | ✅ Complete (v0.7.0) |
| English Documentation | ✅ Partial (README.en.md, ARCHITECTURE.md) |
| `hcc desktop init` (wizard) | ✅ Complete (v0.7.0) |
| `hcc desktop submit` | ✅ Complete (v0.8.0) |
| `hcc get <profile>` (super cmd) | ✅ Complete (v0.8.0) |
| CI Pipeline (GitHub Actions) | ✅ Complete (v0.8.0) |
| AUR PKGBUILD (hcc-bin, hcc-git) | ✅ Prepared (v0.8.0) |
| ShellCheck CI | ✅ Complete (v0.8.0) |
| Tech Debt: Action Engine | ✅ Refactored (v0.8.0) |
| Tech Debt: Deployment Service | ✅ Refactored (v0.8.0) |
| Tech Debt: Dependency Service | ✅ Refactored (v0.8.0) |

---

# 6. Service Layer

| Service | Path | Status |
|---|---|---|
| package_service | `services/package_service.sh` | ✅ Active |
| aur_service | `services/aur_service.sh` | ✅ Active |
| backup_service | `services/backup_service.sh` | ✅ Active |
| desktop_service | `services/desktop_service.sh` | ✅ Active |
| filesystem_service | `services/filesystem_service.sh` | ✅ Active |
| git_service | `services/git_service.sh` | ✅ Active |
| hook_service | `services/hook_service.sh` | ✅ Active |
| dependency_service | `services/dependency_service.sh` | ⚠️ Needs redesign |

---

# 7. Package Abstraction Layer

```
lib/package/
├── detect.sh     — auto-detect: pacman, apt, dnf, zypper, nix, xbps, portage, apk
│                   AUR helpers: yay, paru, trizen, pamac
├── install.sh    — pm_install, pm_install_aur (auto-detects PM on first call)
├── remove.sh     — pm_remove unified
├── query.sh      — pm_installed, pm_available
└── map.sh        — pm_map_name: cross-distro name mapping
```

Usage:
```bash
pm_install hyprland kitty fish        # installs via detected PM
pm_install_aur quickshell-git         # installs via detected AUR helper
pm_installed hyprland                  # true/false
pm_remove hyprland                     # removes via detected PM
pm_map_name fd                         # → "fd-find" on Debian
```

All 4 operations files delegate to `pm_*`:
- `package_operation.sh` → `pm_install`
- `aur_operation.sh` → `pm_install_aur`
- `package_query.sh` → `pm_installed`
- `aur_query.sh` → `pm_installed`

---

# 8. TOML Config Support

```
lib/config/read.sh
├── config_read()                    — tries package.toml → package.conf
├── config_parse_toml_python()       — Python 3.11+ tomllib (fallback tomli)
├── config_parse_toml_bash()         — pure-Bash parser (key-value, tables, arrays, bools)
└── config_toml_to_legacy()          — TOML vars → PACMAN_PACKAGES, AUR_PACKAGES, etc.
```

### Flow

```
desktop_registry_load_package <id>
  → config_read()  (tries .toml → .conf)
    → config_parse_toml_python()  (or _bash)
    → config_toml_to_legacy()     (convert to legacy vars)
```

### Profiles migrated

| Profile | Required | AUR | Git repos |
|---|---|---|---|
| `end-4` | 75 | 10 | 1 |
| `mailong2401` | 16 | 7 | 1 |

---

# 9. Desktop Registry

```
desktops/
├── registry.conf          ← Central registry index
├── mailong2401/
│   ├── package.conf       ← Legacy format (backward compat)
│   ├── package.toml       ← New TOML format
│   ├── payload/           ← Config files
│   └── hooks/
└── end-4/
    ├── package.conf
    ├── package.toml
    ├── payload/
    └── hooks/
```

Capabilities:
- `hcc desktop list` — list available desktops
- `hcc desktop install <id|url|dir>` — install from registry, GitHub URL, or local dir
- `hcc desktop search <keyword>` — search community registry
- `hcc desktop uninstall <id>` — remove desktop + rollback
- Auto-detect packages from `.config/`, `install.sh`, `.gitmodules`
- AI-powered package.conf generation via Gemini

---

# 10. Profile Management

```
~/.local/share/hcc/profiles/
├── <id>/profile.conf      ← installed profile metadata
└── active                 ← active profile ID (symlink target)

~/.config/hcc/
└── session-active         ← active profile for DM launcher
```

Commands:
```bash
hcc profile list           # List installed profiles
hcc profile status         # Show active profile
hcc profile switch <id>    # Change active profile
```

---

# 11. Session Management

Session isolation (symlink-based session switching) was **removed** after repeated login-screen freezes. Current approach:

```
hcc desktop install <id>
  → installs configs directly to $HOME
  → registers profile
  → profile switch = just changes active marker

Login screen:
  /usr/share/wayland-sessions/hcc.desktop
    → /usr/lib/hcc/session-launcher
      → reads ~/.config/hcc/session-active
      → exec /usr/bin/Hyprland
```

The launcher (`lib/launchers/session-launcher.sh`) is simplified: no isolation, no symlinks. Just reads active profile and launches Hyprland.

---

# 12. Desktop Packages Available

| ID | Author | Required | AUR | Description |
|---|---|---|---|---|
| `mailong2401` | Mailong2401 | 16 | 7 | Hyprland + Quickshell cartoon-shell + Kitty + Fish |
| `end-4` | end-4 | 75 | 10 | illogical-impulse: Quickshell widgets, AI, Material Design |

---

# 13. AI Integration

| Feature | Path | Description |
|---|---|---|
| AI setup | `lib/desktop_registry.sh` | Interactive API key setup |
| AI analyze | `lib/desktop_registry.sh` | Send repo to Gemini 2.0 Flash → auto-generate `package.conf` |
| AI CLI | `lib/commands/ai_command.sh` | `hcc ai setup / remove-key / status / help` |
| AI fallback | Auto-detect + manual edit | If AI fails or no API key |

---

# 14. Testing Status

## Unit tests (26 tests)
| Test | Description |
|---|---|
| `bootstrap_test` | Bootstrap loads without errors |
| `planner_test` | Plan creation, actions, rendering |
| `plan_builder_test` | Plan builder functions |
| `plan_validator_test` | Plan validation |
| `plan_record_test` | Record creation, type/arg extraction |
| `transaction_test` | Transaction registration and rollback |
| `transaction_stack_test` | Transaction with filesystem operations |
| `command_runner_test` | Normal, dry-run, verbose modes |
| `profile_registry_test` | Registration, activation, loading |
| `repository_inspector_test` | Manifest validation |
| `desktop_package_payload_test` | Self-contained payloads |
| `desktop_prepare_backup_test` | Pre-install backup |
| `backup_service_test` | Backup directory copy |
| `backup_planner_test` | Backup plan generation |
| `package_service_test` | Package install |
| `aur_service_test` | AUR package install |
| `git_service_test` | Git clone/update |
| `filesystem_service_test` | Filesystem copy operations |
| `external_detect_test` | 28 tests for package detection, scripts, git, copy items |

## CLI tests (10 tests)
| Test | Description |
|---|---|
| `version` | `hcc --version` |
| `help` | `hcc help` |
| `doctor` | `hcc doctor` |
| `cleanup` | `hcc cleanup` |
| `backup` | `hcc backup` |
| `restore list` | `hcc restore` |
| `theme list` | `hcc theme list` |
| `plugin list` | `hcc plugins` |
| `profile list` | `hcc profile list` |
| `inspect` | `hcc inspect` |

All 36 tests pass.

---

# 15. Technical Debt

| Item | Status | Notes |
|---|---|---|
| Action Engine | ✅ Refactored (v0.8.0) | Now uses `action_engine_execute_plan()` |
| Deployment Service | ✅ Refactored (v0.8.0) | Extracted from desktop_pipeline |
| Dependency Service | ✅ Refactored (v0.8.0) | Now checks dependencies instead of installing |
| Session isolation code | Removed | Was causing login-screen freezes |
| Distro support | Arch-only tested | Package abstraction layer supports 8 PMs but untested |
| English documentation | Partial | README.en.md exists, ARCHITECTURE.md is bilingual |

---

# 16. Phase 1 — Package Abstraction + TOML Config (2026-07-25)

> Commit: `679e4c3`

### Package abstraction layer (lib/package/)

| File | Description |
|---|---|
| `detect.sh` | Auto-detect 8 package managers + 4 AUR helpers |
| `map.sh` | Cross-distro package name mapping |
| `install.sh` | `pm_install` + `pm_install_aur` unified |
| `remove.sh` | `pm_remove` unified |
| `query.sh` | `pm_installed` + `pm_available` |

### TOML config (lib/config/)

| File | Description |
|---|---|
| `read.sh` | Python + Bash parsers, legacy converter |
| `desktops/*/package.toml` | Both profiles migrated |

### Changed files

| File | Change |
|---|---|
| `lib/desktop_registry.sh` | `desktop_registry_load_package()` calls `config_read()` → TOML first, fallback to shell |
| `lib/planners/package_planner.sh` | Support `PACKAGES=` field (backward compat) |
| `operations/*.sh` | 4 operation files delegate to `pm_*` |
| `lib/bootstrap.sh` | Loads `package.sh` + `config.sh` |
| `lib/bootstrap/package.sh` | New — loads `lib/package/*.sh` |
| `lib/bootstrap/config.sh` | New — loads `lib/config/read.sh` |
| `README.md` | Rewritten with full docs, commands, installation guide |

### Verification

- All 26 unit tests pass
- All 10 CLI tests pass
- `config_parse_toml_python` correctly parses both profiles
- `config_toml_to_legacy` correctly populates all legacy variables
- `desktop_registry_load_package` reads TOML → populates PACMAN_PACKAGES (75 for end-4), AUR_PACKAGES (10), GIT_REPOSITORIES, COPY_ITEMS

---

# 17. v0.7.0 — Flatpak, Batch Install, Desktop Update, DM Abstraction, Init Wizard (2026-07-25)

> Commit: `5cf1e2e`

### Flatpak support (`lib/package/`)

| File | Change |
|---|---|
| `detect.sh` | Added flatpak detection (lowest priority PM + `HCC_HAS_FLATPAK` flag) |
| `install.sh` | Added `__pm_install_batch flatpak` case |
| `remove.sh` | Added flatpak remove case |
| `query.sh` | Added `pm_installed` + `pm_available` for flatpak |
| `map.sh` | 14 flatpak name mappings (kitty, firefox, mpv, etc.) |

### Batch install (`lib/package/install.sh`)

- `pm_install` now collects all packages, maps names, checks installed status, then issues **one `sudo` command** per PM (except nix which installs one-by-one)
- `pm_install_all` alias for clarity
- Drastically reduces `sudo` prompts during install

### Display Manager abstraction (`lib/display_manager/`)

| Function | Description |
|---|---|
| `dm_detect()` | Auto-detect SDDM/GDM/LightDM/greetd via systemd service + binary check |
| `dm_install_entry()` | Create `.desktop` entry in correct DM sessions directory |
| `dm_remove_entry()` | Remove `.desktop` entry |

Updated `lib/detect.sh` `detect_display_manager()` to delegate to `dm_detect()`.
Updated `lib/desktop_pipeline.sh` to use `dm_install_entry()` instead of hardcoded SDDM path.

### `hcc desktop update <id>` (`modules/desktop_update.sh`)

- Loads profile registry to get source info
- If source is git URL: `git pull` in external dir, re-load package
- If source is local: re-load from bundled registry
- Re-generates plan, checks conflicts, confirms, executes
- Re-registers profile with updated version

### `hcc desktop init [dir]` (`modules/desktop_init.sh`)

Interactive wizard that:
- Asks for name, ID, version, author, description, license
- Scans `~/.config/` to auto-detect packages (via `desktop_external_detect_from_home_config`)
- Scans config dirs for `COPY_ITEMS` entries
- Detects git repos in config dirs
- Generates `package.toml`, `package.conf` (legacy), `hcc.manifest`, `hooks/post-install.sh`
- Optionally copies current config files into `payload/`

### `install.sh` improvements

- Non-Arch OS now shows **warning** instead of hard fail (distro-agnostic)
- AUR helper detection expanded: `yay`, `paru`, `trizen`, `pamac`
- Session launcher installation uses proper `if/else` (not `&&/||`)

### English documentation

- `README.en.md` — full English translation of README
- `docs/ARCHITECTURE.md` — rewritten bilingual (Vietnamese + English)

### Verification

- All 36 tests pass
- Version bump 0.6.1 → 0.7.0

---

# 18. Bugs Fixed in Config Parser

| # | Bug | Fix |
|---|---|---|
| 1 | Python `emit()` used `obj` as param but referenced `v` → `UnboundLocalError` | Renamed param to `val` |
| 2 | Pipe into `while read` ran in subshell → `printf -v` lost all variables | Replaced pipe with process substitution |
| 3 | Trailing dot in key (`name.` → `NAME_`) | Strip trailing dot before `tr` |
| 4 | LIST entries skipped (no length stored) | Store as `__LEN` suffix |
| 5 | `config_toml_to_legacy` looked for wrong var names (`PACKAGES__LEN` instead of `PACKAGES_REQUIRED__LEN`) | Updated to match Python emit naming |

---

# 18. CLI Command Reference

| Command | Description |
|---|---|
| `hcc doctor` | System health check |
| `hcc inventory` | System component inventory |
| `hcc cleanup` | Show cache sizes |
| `hcc inspect <path\|url>` | Inspect a desktop repository |
| `hcc desktop list` | List available desktops |
| `hcc desktop search <keyword>` | Search community registry |
| `hcc desktop install <name\|url\|dir>` | Preview and install desktop |
| `hcc desktop uninstall <id>` | Remove a desktop with rollback |
| `hcc profile list` | List installed profiles |
| `hcc profile status` | Show active profile |
| `hcc profile switch <id>` | Change active profile |
| `hcc session setup-login` | Create DM login entries |
| `hcc backup` | Create config backup snapshot |
| `hcc restore [id]` | Restore from backup |
| `hcc theme list` | List themes |
| `hcc theme install <name>` | Install a theme |
| `hcc theme uninstall <name>` | Uninstall a theme |
| `hcc plugins` | List plugins |
| `hcc plugin install <name>` | Install a plugin |
| `hcc plugin uninstall <name>` | Uninstall a plugin |
| `hcc ai setup` | Configure AI API key |
| `hcc ai remove-key` | Remove AI API key |
| `hcc ai status` | Check AI configuration |
| `hcc ai help` | AI integration help |
| `hcc help` | Show help |
| `hcc --version` | Show version |

---

# 19. Next Steps

## Short-term

1. **Create community-registry GitHub repo** — `hyprland-control-center/community-registry` với `registry.txt`
2. **Publish AUR packages** — upload `dist/aur/hcc-bin` and `dist/aur/hcc-git` to AUR
3. **Test Gemini API end-to-end** — install from real URL without package.conf
4. **Test on non-Arch distro** — Fedora/Ubuntu VM to validate PM abstraction + flatpak

## Medium-term

5. **Enable CI on GitHub** — push `.github/workflows/test.yml` and verify it runs
6. **Add 5+ community desktop profiles** — recruit from Hyprland community
7. **Profile dependencies graph** — visual tree of what gets installed

## v1.0.0

8. Remove bundled packages from HCC repo
9. Full English documentation (README.en.md → README.md)

---

# 20. Rules For Future Sessions

Always read PROJECT_STATE.md first.

Never redesign architecture without auditing current code.

Prefer completing existing abstractions over creating new ones.

Do not replace working pipelines.

Refactor incrementally.

Every architectural decision must preserve Desktop Install functionality.
