# HCC Architecture & Roadmap

> Goal: **distro-agnostic**, modular, scalable — from Arch Linux to any Linux distro.

---

## 1. Vision

**Hyprland Control Center** becomes the standard tool for **installing and managing Hyprland desktops** on any Linux distro:

- 1 command → complete Hyprland desktop (packages + configs)
- Choose between community desktop profiles
- Safe: backup first, rollback on failure
- Login screen integration (SDDM/GDM/LightDM/greetd)

---

## 2. Architecture

```
                    ┌──────────────────┐
                    │   hcc CLI (Bash) │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
    ┌─────────────────┐ ┌──────────┐ ┌──────────────┐
    │ Package Manager │ │ Desktop  │ │ Display      │
    │ Abstraction     │ │ Registry │ │ Manager      │
    │ Layer           │ │ (git)    │ │ Integration  │
    └────────┬────────┘ └──────────┘ └──────┬───────┘
             ▼                               ▼
    ┌─────────────────┐             ┌──────────────────┐
    │ pacman (Arch)   │             │ SDDM / GDM       │
    │ apt (Debian)    │             │ LightDM / greetd │
    │ dnf (Fedora)    │             └──────────────────┘
    │ zypper (openSUSE)│
    │ nix (NixOS)     │
    │ xbps (Void)     │
    │ portage (Gentoo)│
    │ apk (Alpine)    │
    └─────────────────┘

    ┌──────────────────────────────────────────────┐
    │              Desktop Profile                  │
    │  package.toml + payload/ + hooks/             │
    │  (distro-agnostic format)                     │
    └──────────────────────────────────────────────┘
```

### 2.1 Package Manager Abstraction Layer

Arch → universal:

```
lib/package/
  detect.sh   — auto-detect: pacman / apt / dnf / nix / xbps / portage / apk / zypper
  install.sh  — pm_install <packages> → dispatch correct backend (batched)
  remove.sh   — pm_remove <packages>
  query.sh    — pm_installed <package> → true/false
  map.sh      — cross-distro name mapping
```

### 2.2 Desktop Profile Format (TOML)

Cross-platform format replacing shell-based `package.conf`:

```toml
name = "End-4 Dots"
id = "end-4"
version = "1.0"
author = "end-4"

[packages]
required = ["hyprland", "kitty", "waybar", "wofi"]
aur = ["quickshell-git", "matugen-bin"]

[config]
payload_root = "."
install_path = "~"

[hooks]
post_install = "hooks/post-install.sh"
```

### 2.3 Desktop Registry

```
desktops/
  end-4/
    package.toml         ← TOML format (primary, with shell fallback)
    package.conf         ← Legacy shell format
    payload/...
    hooks/post-install.sh
  mailong2401/
    package.toml
    package.conf
    payload/...
  registry.conf          ← Local registry index
```

### 2.4 Display Manager Integration

```
lib/display_manager/
  detect.sh  — SDDM / GDM / LightDM / greetd auto-detection
```

| DM | Detection | Path |
|---|---|---|
| SDDM | systemd service | `/usr/share/wayland-sessions/` |
| GDM | systemd service | `/usr/share/wayland-sessions/` |
| LightDM | binary check | `/usr/share/wayland-sessions/` (+ xsessions) |
| greetd | systemd service | `/usr/share/wayland-sessions/` |

### 2.5 Session Launcher

```bash
/usr/lib/hcc/session-launcher

Flow:
1. Read active profile (~/.config/hcc/session-active)
2. Launch /usr/bin/Hyprland
```

Simplified: no session isolation, no symlinks. Just reads the profile and execs Hyprland.

---

## 3. Data Directory Layout

```
~/.local/share/hcc/
├── profiles/                 ← Installed profile registry
│   ├── end-4/profile.conf
│   ├── mailong2401/profile.conf
│   └── active                ← Active profile ID
├── desktops/                 ← Externally cloned repos
│   └── <user>-<repo>/
│       ├── package.toml
│       └── payload/
├── backups/                  ← Pre-install snapshots
│   └── <timestamp>-<profile>/
└── logs/

~/.config/hcc/
├── hcc.conf                  ← User config
├── session-active            ← Active profile for DM launcher
└── ai.conf                   ← Gemini API key (optional)
```

---

## 4. Layer Architecture

```
┌─────────────────────────────────────────────┐
│                  CLI Layer                   │
│  bin/hcc → lib/dispatcher.sh               │
├─────────────────────────────────────────────┤
│                Module Layer                  │
│  modules/*.sh  (doctor, desktop, profile…) │
├─────────────────────────────────────────────┤
│               Planner Layer                 │
│  lib/planners/*.sh (package, aur, git, copy)│
├─────────────────────────────────────────────┤
│           Execution Engine                  │
│  lib/plan_executor.sh + action_dispatcher  │
├─────────────────────────────────────────────┤
│              Service Layer                  │
│  services/*.sh (package, aur, git, backup…)│
├─────────────────────────────────────────────┤
│             Operations Layer                │
│  operations/*.sh (atomic shell wrappers)    │
├─────────────────────────────────────────────┤
│           Abstraction Layers                │
│  lib/package/   lib/config/   lib/display_mgr│
└─────────────────────────────────────────────┘
```

---

## 5. Status (v0.6.1)

| Component | Status |
|---|---|
| Package Abstraction Layer | ✅ Complete (8 PMs + 4 AUR helpers) |
| TOML Config Support | ✅ Complete (Python + Bash parsers) |
| Desktop Registry | ✅ Complete |
| URL Install | ✅ Complete (with auto-detect + AI + interactive) |
| AI Integration (Gemini) | ✅ Complete |
| Planner / Executor | ✅ Complete |
| Rollback / Backup | ✅ Complete |
| Profile Management | ✅ Complete |
| Theme & Plugin System | ✅ Complete |
| Display Manager Abstraction | ✅ Complete (detect + session entry) |
| `hcc desktop update` | ✅ Complete |
| Session Launcher | ✅ Simplified (no isolation) |
| Tests | 36 tests passing |

### Technical Debt

| Item | Notes |
|---|---|
| Action Engine | Stub — prints action payload only |
| Deployment Service | Placeholder — logic in desktop_pipeline |
| Dependency Service | Needs redesign |
| Distro support | Arch-only tested; abstraction exists for 8 PMs |
| CI/CD | Not yet set up |

---

## 6. Roadmap

### Short-term

1. Test on non-Arch distro (Fedora/Ubuntu VM)
2. Community registry (GitHub repo + `hcc desktop submit`)
3. `hcc get <profile>` — super command (detect → install → apply)

### Medium-term

4. Flatpak support
5. AUR package (`hcc-bin`, `hcc-git`)
6. GitHub Actions CI (test on Arch, Fedora, Ubuntu)
7. Resolve tech debt (Action Engine, Deployment Service, Dependency Service)

### v1.0.0

8. Remove bundled packages from HCC repo
9. Full English documentation
10. ShellCheck CI

---

## 7. Design Principles

1. **Distro-agnostic first** — every feature must work on ≥2 distros before merge
2. **Safe by default** — backup before overwrite, dry-run always available
3. **Modular** — each layer is independent, backends can be swapped
4. **Simple over clever** — Bash for CLI, rewrite only if performance/security demands
5. **Community-driven** — profile format must be easy to contribute (TOML > shell, git-based registry)
6. **Progressive complexity** — 1 command for newbies, many options for power users
