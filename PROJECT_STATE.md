# Hyprland Control Center (HCC) — Project State

*Last updated: 2026-07-28 (v0.8.0)*
*See `docs/RELEASE.md` for deployment instructions.*

---

## 1. Executive Summary

HCC là Bash framework để cài đặt và quản lý Hyprland desktop — đã phát triển từ CLI tool đơn giản thành distro-agnostic system với package abstraction, TOML config, AUR packages, CI/CD, và community registry.

**Current status: v0.8.0 — published on AUR, working on Arch Linux.**

| Metric | Value |
|---|---|
| Lines of code | 6,835 |
| Script files | 179 |
| Tests | 36 (26 unit + 10 CLI) |
| Git commits | 32 |
| Contributors | laosifu |
| Package managers | 9 (pacman, apt, dnf, zypper, nix, xbps, portage, apk, flatpak) + 4 AUR helpers |
| AUR packages | hcc-bin (stable), hcc-git (dev) |
| GitHub release | v0.8.0 |

---

## 2. Architecture

```
CLI
  ↓
Module (19 modules)
  ↓
Planner → Action DSL → Executor
  ↓
Dispatcher
  ↓
Services (7 services)
  ↓
Operations (6 operation files)
  ↓
Shell Commands
```

### Core layers

| Layer | Path | Purpose |
|---|---|---|
| Package abstraction | `lib/package/` | 9 PMs + 4 AUR helpers — detect, install, remove, query, map |
| TOML config | `lib/config/read.sh` | Python + Bash parser, legacy var converter |
| Desktop registry | `lib/desktop_registry.sh` | Load/validate/list/search desktop packages — local + community |
| Display Manager | `lib/display_manager/detect.sh` | SDDM/GDM/LightDM/greetd abstraction |
| Planner | `lib/planners/` | Generate plan (package, aur, git, copy) |
| Executor | `lib/plan_executor.sh` | Execute with rollback + progress |
| Services | `services/` | Package, AUR, git, filesystem, backup, hook, deployment |
| Operations | `operations/` | Atomic wrappers around `pm_*` and file commands |
| Session launcher | `lib/launchers/session-launcher.sh` | DM entry: reads session-active → exec Hyprland |

---

## 3. What HCC Can Do

### 🖥️ Desktop Management

| Command | Description |
|---|---|
| `hcc desktop list` | List all available desktop profiles |
| `hcc desktop search <kw>` | Search community registry (HCC repo's registry.txt) |
| `hcc desktop install <id\|url\|dir>` | Install desktop with preview, plan, rollback |
| `hcc desktop uninstall <id>` | Remove with full rollback |
| `hcc desktop update <id>` | Pull latest source and re-install |
| `hcc desktop init [dir]` | Interactive wizard to create new profiles |
| `hcc desktop submit <id>` | Guide user through PR submission |
| `hcc get <profile>` | Super command: auto-install HCC → install → setup-login |

### 📦 Package Abstraction

| Feature | Details |
|---|---|
| 9 PMs | pacman, apt, dnf, zypper, nix, xbps, portage, apk, flatpak |
| 4 AUR helpers | yay, paru, trizen, pamac |
| Batch install | One `sudo` call per PM (except nix) — detects already-installed, maps names |
| Flatpak | detect, install, remove, query, 14 name mappings |

### ⚙️ System Integration

| Feature | Details |
|---|---|
| Display Manager | Auto-detect SDDM/GDM/LightDM/greetd + install/remove `.desktop` entry |
| Session launcher | Single DM entry → reads `session-active` → exec `/usr/bin/Hyprland` |
| Profile system | List, status, switch — profiles in `~/.local/share/hcc/profiles/` |
| Backup/Restore | Snapshot config before install, restore from backup |
| Doctor | System health check (OS, Hyprland, session, DM, hardware) |

### 🤖 AI Integration

| Feature | Details |
|---|---|
| Gemini 2.0 Flash | Auto-generate `package.conf` from GitHub URL |
| `hcc ai setup/status/remove-key/help` | API key management |

### 📋 Testing

| Suite | Tests | What |
|---|---|---|
| Unit tests | 26 | Bootstrap, planner, plan builder, plan validator, transaction, command runner, profile registry, desktop package, backup, services, detection (28 sub-tests) |
| CLI tests | 10 | version, help, doctor, cleanup, backup, restore, theme, plugin, profile, inspect |

---

## 4. Bundled Desktop Profiles

| ID | Author | Packages | AUR | Description |
|---|---|---|---|---|
| `mailong2401` | Mailong2401 | 16 | 7 | Hyprland + Quickshell cartoon-shell + Kitty + Fish |
| `end-4` | end-4 | 75 | 10 | illogical-impulse: Quickshell widgets, AI, Material Design |

Both have `package.toml` (TOML) + `package.conf` (legacy) + `payload/` + `hooks/`.

---

## 5. Community Registry

- **Location:** `docs/community-registry/registry.txt` (within HCC repo — no separate repo)
- **URL:** `https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/docs/community-registry/registry.txt`
- **Search:** `hcc desktop search <keyword>`
- **Submit:** Edit `registry.txt` + PR to HCC repo (guided by `hcc desktop submit`)

---

## 6. AUR Packages

| Package | Type | Status | Build source |
|---|---|---|---|
| `hcc-bin` | Stable release | ✅ Published (v0.8.0-2) | GitHub tarball |
| `hcc-git` | Git version | ✅ Published (v0.8.0) | GitHub git clone |

### Known AUR fixes applied

1. **System path detection** — `bin/hcc` detects `/usr/bin` install → `PROJECT_ROOT=/usr/share/hcc`
2. **LOG_DIR** — changed from `$PROJECT_ROOT/logs` (not writable) to `$HOME/.local/share/hcc/logs`

### Build files

```
dist/aur/
├── hcc-bin/
│   ├── PKGBUILD        — v0.8.0-2, patches bin/hcc + logger.sh
│   ├── hcc.install     — post-install messages
│   └── .SRCINFO
└── hcc-git/
    ├── PKGBUILD
    ├── hcc.install
    └── .SRCINFO
```

---

## 7. CI/CD

- `.github/workflows/test.yml` — Arch Linux container test + ShellCheck
- Runs on push/PR to main
- ShellCheck config: `.shellcheckrc`

---

## 8. Installation Methods

### AUR (recommended for Arch)
```bash
yay -S hcc-bin       # stable
hcc doctor           # verify
```

### From source
```bash
git clone https://github.com/laosifu/Hyprland-Control-Center
cd Hyprland-Control-Center
bash hcc --version
```

---

## 9. Version History

| Version | Date | Highlights |
|---|---|---|
| v0.8.0 | 2026-07-28 | AUR publish, community registry, super command, CI, tech debt, release |
| v0.7.0 | 2026-07-25 | Flatpak, batch install, DM abstraction, desktop init/update wizard |
| v0.6.1 | 2026-07-25 | AI CLI, community search, bugs fixed in TOML parser |
| v0.6.0 | 2026-07-24 | TOML config, Python parser, Gemini API integration |
| v0.5.0 | 2026-07-23 | Profile system, registration, activation, session launcher |
| v0.4.0 | 2026-07-22 | Desktop registry, URL install, external manifest, conflict detection |
| v0.3.0 | 2026-07-22 | Plugin system, theme system, CLI framework expansion |
| v0.2.0 | 2026-07-21 | Backup/restore, uninstall, test framework |
| v0.1.0 | 2026-07-20 | Initial: CLI, planner, executor, basic desktop install |

---

## 10. Technical Debt & Known Issues

| Item | Status | Notes |
|---|---|---|
| Action Engine | ✅ Refactored | `action_engine_execute_plan()` |
| Deployment Service | ✅ Refactored | Extracted from desktop_pipeline |
| Dependency Service | ✅ Refactored | Now checks, doesn't install |
| Session isolation | Removed | Was causing login freezes |
| Distro support | ⚠️ Arch-only tested | 9 PMs supported but untested on non-Arch |
| English docs | ⚠️ Partial | README.en.md, ARCHITECTURE.md bilingual |
| `hcc session setup-login` | ✅ Fixed | Was broken, now works with system path fix |
| `sudo hcc` | ⚠️ Run as root | HOME → `/root` may affect config/session paths |

---

## 11. CLI Command Reference (27 commands)

```
hcc doctor                     System health check
hcc inventory                  System component inventory
hcc cleanup                    Show cache sizes
hcc inspect <path|url>         Inspect a desktop repository
hcc backup                     Create config backup snapshot
hcc restore [id]               Restore from backup
hcc profile list               List installed profiles
hcc profile status             Show active profile
hcc profile switch <id>        Change active profile
hcc desktop list               List available desktops
hcc desktop search <keyword>   Search community registry
hcc desktop install <id|url>   Preview and install desktop
hcc desktop uninstall <id>     Remove desktop with rollback
hcc desktop update <id>        Update installed desktop
hcc desktop init [dir]         Create new desktop profile (wizard)
hcc desktop submit <id>        Guide to submit to registry
hcc get <profile>              Super command (install → setup-login)
hcc session setup-login        Create DM login entries
hcc theme list/install/uninstall
hcc plugin list/install/uninstall
hcc ai setup/status/remove-key/help
hcc help                       Show help
hcc --version                  Show version
```

---

## 12. Potential Features for Future Development

### Short-term (v0.9.x)

| Feature | Description |
|---|---|
| **Auto-update** | `hcc self-update` — check AUR version, update if newer |
| **Non-Arch E2E test** | Test on Fedora/Ubuntu VM to validate PM abstraction |
| **Gemini E2E test** | Test `hcc desktop install <url>` without package.conf |
| **Desktop uninstall confirm** | Show what will be removed, ask confirmation |
| **Session launcher sudo fix** | Handle `sudo hcc session setup-login` with correct HOME |
| **`hcc doctor` recommendations** | Suggest fixes for detected issues |

### Medium-term (v1.0.0)

| Feature | Description |
|---|---|
| **TUI mode** | Text-based interactive UI (whiptail/fzf) for desktop selection |
| **Profile dependencies graph** | Visual tree of packages/configs |
| **5+ community profiles** | Recruit from Hyprland community |
| **Config diff** | Show changes before install |
| **`hcc desktop export`** | Export installed profile as package.toml |
| **Complete English docs** | README.en.md → README.md |
| **Flatpak GUI apps support** | Install Flatpak apps beyond config files |

### Long-term (v2.0.0)

| Feature | Description |
|---|---|
| **Ansible/Puppet integration** | Idempotent config management |
| **Web dashboard** | Web UI for managing desktops |
| **NixOS module** | Native Nix flake support |
| **Multiple profile stacking** | Layer multiple profiles |
| **Docker dev environment** | Test profiles in containers |

---

## 13. Development Principles

```
Read → Understand → Design → Implement → Test → Log → Continue
```

- Never skip layers
- Never refactor blindly
- Desktop installation must remain functional during refactoring
- Prefer completing existing abstractions over creating new ones
- Do not replace working pipelines
- Refactor incrementally
- Every architectural decision must preserve Desktop Install functionality
