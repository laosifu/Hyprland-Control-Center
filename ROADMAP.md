# HCC Roadmap: Desktop Deployment Platform for Linux

## Product Vision

HCC is a **Desktop Deployment Platform** — not an installer.
Users paste a GitHub URL → HCC analyzes, previews, checks compatibility,
calculates a deployment plan, installs, creates a profile, enables rollback,
and supports future updates.

## Current Status (v0.9.2)

| Area | State |
|------|-------|
| CLI + TUI | 4 backends (fzf/whiptail/dialog/select) |
| Desktop install from URL | Working + AI fallback |
| Community profiles | 10 profiles |
| Profile management | Registration + listing works, switching unimplemented |
| Package manager abstraction | Detects 9 PMs, maps only 4, Arch-biased |
| Rollback | Transaction stack exists, cannot undo package installs |
| Plugin system | Structural framework only, no lifecycle |
| Tests | 47 smoke-level tests |
| Distribution | AUR (hcc-bin, hcc-git), self-update |
| Desktop detection | Single env var (`$XDG_CURRENT_DESKTOP`) |
| Distro detection | Reads `$ID` only, no `ID_LIKE` |
| Config format | TOML (custom bash parser) + legacy `.conf` |
| Multi-distro support | Arch only in practice |

---

## Phase 1: Alpha — Prove Architecture (v0.10–v0.15)

Goal: Working prototype that proves the concept for technical users.

### 1.1 Multi-Distro Foundation

**Problem**: `pacman` hardcoded in `map.sh`, `install.sh`, `remove.sh`, `query.sh`.
The manifest format lacks distro-specific package maps.

**Tasks**:
- [ ] Refactor `lib/package/map.sh` to support per-distro package mapping:
  ```toml
  [packages.arch]
  required = ["hyprland", "kitty"]
  [packages.debian]
  required = ["hyprland", "kitty"]
  [packages.fedora]
  required = ["hyprland", "kitty"]
  ```
- [ ] Update TOML parser to read distro-specific blocks
- [ ] Update `desktop_package_is_supported()` in `lib/desktop_packages.sh` to check `ID_LIKE` (catch EndeavourOS, CachyOS, Manjaro as `arch`)
- [ ] Add package name maps for Debian, Fedora, openSUSE, Void (at minimum 20 common Hyprland packages each)
- [ ] Add integration test: install same desktop on 3 distro profiles (mock)

### 1.2 Reliability Layer

**Problem**: No pre-install sanity checks, no conflict detection, rollback is shallow.

**Tasks**:
- [ ] `hcc doctor` enhancements: check disk space, existing DE conflicts, PM health, network
- [ ] Pre-install compatibility report: "This desktop requires X, Y, Z. Your system has A, B. Conflicts: C."
- [ ] Full rollback v1: snapshot approach — before install, snapshot config dirs (`~/.config/hypr/`, `~/.config/waybar/`, etc.), restore on failure
- [ ] `hcc rollback` command: list snapshots, restore to any previous state
- [ ] Transaction tests: mock pm_install to test rollback of mixed operations

### 1.3 Manifest Standard v1

**Problem**: No standardized format that HCC and community can agree on.

**Tasks**:
- [ ] Define `hcc.manifest` v1 spec:
  ```toml
  [manifest]
  version = "1"
  type = "desktop-profile"

  [meta]
  name = "My Desktop"
  id = "my-desktop"
  version = "2.1"
  author = "user"
  description = "A Hyprland rice"
  supported_distros = ["arch", "debian", "fedora"]

  [packages.arch]
  required = ["hyprland", "kitty"]
  aur = ["some-aur-package"]

  [packages.debian]
  required = ["hyprland", "kitty"]

  [config]
  payload_root = "dotfiles"
  copy_items = [".config/hypr|~/.config/hypr"]

  [git]
  repositories = [{ url = "https://github.com/user/dots", path = "dotfiles" }]
  ```
- [ ] Validator: `hcc manifest validate <path>` — check structure, required fields
- [ ] Generator: `hcc manifest init` — interactive wizard to create manifest
- [ ] Update existing `desktops/` to v1 format
- [ ] Support URL-based manifests: `hcc desktop install https://github.com/user/repo` reads `hcc.manifest`

### 1.4 Community Repository v1

**Problem**: Flat text file registry is unscalable.

**Tasks**:
- [ ] Registry API spec: JSON registry at `raw.githubusercontent.com` with structured metadata
  ```json
  {
    "id": "end-4",
    "name": "dots-hyprland",
    "version": "2.0",
    "author": "end-4",
    "description": "...",
    "manifest_url": "https://raw.githubusercontent.com/end-4/dots-hyprland/main/hcc.manifest",
    "supported_distros": ["arch"],
    "tags": ["hyprland", "minimal"],
    "screenshots": ["https://..."],
    "stars": 4200
  }
  ```
- [ ] `hcc registry search` — keyword search, filter by distro, sort by stars
- [ ] `hcc registry submit` — PR-based or auto-submit flow
- [ ] Migration from flat text to JSON registry
- [ ] Registry update: `hcc registry update` fetches latest index

**Deliverable for Alpha**:
```
hcc desktop install https://github.com/user/rice
  → downloads repo, finds hcc.manifest
  → validates manifest
  → shows preview: "Will install: hyprland, kitty, waybar (3 packages). Config changes: ~/.config/hypr/, ~/.config/kitty/"
  → confirms with user
  → installs with rollback registration
  → creates profile
  → reports result
```

---

## Phase 2: Beta — Stable Core (v0.16–v0.25)

Goal: Feature-complete for daily use by technical users.

### 2.1 Profile Switching

**Problem**: Profiles are registered but switching doesn't work.

**Tasks**:
- [ ] `profile_switch()` implementation:
  1. Snapshot current state (backup current config)
  2. Restore target profile's snapshot
  3. Re-apply config files
  4. Activate profile
  5. Report result
- [ ] `hcc profile switch <id>` — CLI + TUI
- [ ] Profile diff: show what changes between profiles before switching
- [ ] Profile rename, delete, export, import
- [ ] Test: switch between 2 profiles, verify config files

### 2.2 Update Engine

**Problem**: No way to update installed desktops.

**Tasks**:
- [ ] `hcc update check` — compare installed version vs registry version
- [ ] `hcc update apply` — re-run planner with new manifest, merge config changes
- [ ] Update notification in TUI main menu
- [ ] Auto-update option (opt-in)
- [ ] Test: simulate update with version bump

### 2.3 Plugin System v1

**Problem**: Plugins exist structurally but have no lifecycle.

**Tasks**:
- [ ] Plugin registry: `~/.local/share/hcc/plugins/` — user-installed plugins
- [ ] `hcc plugin install <url>` — install plugin from URL
- [ ] Plugin hooks: `pre_install`, `post_install`, `pre_switch`, `post_switch`, `pre_remove`
- [ ] Plugin SDK documentation
- [ ] Example: "notify" plugin (sends notification after install)
- [ ] Example: "backup" plugin (adds rsync backup step)

### 2.4 TOML Parser Hardening

**Problem**: Custom bash TOML parser is brittle.

**Tasks**:
- [ ] Test against edge cases: nested tables, inline tables, multi-line strings, special chars
- [ ] Pure-bash fallback improvements: better error messages, validate structure
- [ ] Python parser (`tomllib`) as primary, bash as fallback
- [ ] Config validation: warn on unknown fields, required field checks

### 2.5 Flatpak Integration

**Problem**: Flatpak support exists but is basic.

**Tasks**:
- [ ] Flatpak as first-class package source (not just supplement)
- [ ] Manifest support: `[packages.flatpak]` in manifest
- [ ] `flatpak` PM detection → use Flatpak as primary if system has no native PM
- [ ] Flatpak update: `hcc update` → `flatpak update`
- [ ] Test: install desktop entirely via Flatpak

### 2.6 Nix / Distrobox Support

**Problem**: Limited to traditional PMs.

**Tasks**:
- [ ] Nix profile (not just NixOS) — `nix profile install nixpkgs#hyprland`
- [ ] Distrobox integration: install in container, export apps
- [ ] `hcc doctor --distrobox` or `hcc install --distrobox`

**Deliverable for Beta**:
```
hcc profile switch end-4
  → Current: mailong2401 (v1.0)
  → Target: end-4 (v2.0)
  → Changes: +hyprlock, -wofi, .config/hypr/* (12 files)
  → Proceed? [Y/n]
  → [Backup current] ✓
  → [Restore target] ✓
  → [Activate profile] ✓
  → Done. Logout to see changes.
```

---

## Phase 3: Stable 1.0 — Mass Adoption (v1.0)

Goal: Ready for non-technical users.

### 3.1 Safety & Guardrails

**Tasks**:
- [ ] Dry-run mode: `hcc install --dry-run` shows full plan without executing
- [ ] System restore point before any install (full snapshot)
- [ ] Conflict detection: detect existing DE (KDE/GNOME/Hyprland) and warn
- [ ] "Safe mode": install to temp directory, preview, then apply
- [ ] Recovery CLI: `hcc recover` — last-resort recovery if system breaks
- [ ] Uninstall wizard: step-by-step guide (already partially done)

### 3.2 Preview System

**Tasks**:
- [ ] `hcc preview <url>` — show before installing:
  - Package changes (install/remove)
  - Config file changes (new/modified/conflict)
  - Estimated disk usage
  - Compatibility score
- [ ] Screenshot viewer in TUI (via kitty/chafa/ueberzug)
- [ ] Dependency tree visualization
- [ ] Preview caching (don't re-download every time)

### 3.3 Multi-Distro Coverage

**Tasks**:
- [ ] Test on: Arch, Debian 12, Ubuntu 24.04, Fedora 40, openSUSE Tumbleweed, NixOS, Void
- [ ] CI matrix: test on each distro (Docker)
- [ ] Distro-specific documentation: `hcc help distro-arch`, `hcc help distro-debian`
- [ ] Community package maps: accept PRs for missing package mappings

### 3.4 Localization

**Tasks**:
- [ ] i18n framework (bash-based, key-value files)
- [ ] English + Vietnamese (already partial)
- [ ] TUI menu translations
- [ ] CLI help translations
- [ ] `HCC_LANG=vi` support hardening

### 3.5 Contributor Ecosystem

**Tasks**:
- [ ] `CONTRIBUTING.md` — how to add package maps, manifests, profiles
- [ ] `hcc manifest submit` — submit manifest to community registry via PR
- [ ] CI: validate submitted manifests on PR
- [ ] Plugin marketplace: `hcc plugin search`, ratings
- [ ] Profile badge: "Install with HCC" SVG for GitHub READMEs

### 3.6 Distribution Expansion

**Tasks**:
- [ ] Snap package (Snapcraft)
- [ ] Flatpak (self-contained HCC)
- [ ] Homebrew (Linuxbrew)
- [ ] Docker image: `docker run hcc`
- [ ] COPR (Fedora)
- [ ] PPA (Ubuntu/Debian)
- [ ] Nixpkgs (NixOS)

---

## Architecture Roadmap

### Now (v0.9.x)

```
bin/hcc
  ├── lib/         (monolithic ~70 modules)
  ├── services/    (business logic)
  ├── operations/  (atomic actions)
  ├── modules/     (CLI commands)
  └── tests/       (47 smoke tests)
```

### Alpha (v0.10–0.15)

```
src/
  ├── domain/          (entities, value objects)
  │   ├── manifest/
  │   ├── package/
  │   ├── profile/
  │   └── desktop/
  ├── application/     (use cases)
  │   ├── install/
  │   ├── profile/
  │   ├── update/
  │   └── rollback/
  ├── infrastructure/  (PM, filesystem, git, network)
  │   ├── package/{detect,install,query,remove,map}
  │   ├── filesystem/
  │   ├── git/
  │   └── network/
  ├── presentation/    (CLI, TUI)
  │   ├── cli/{commands,parsing}
  │   └── tui/{backends,menus}
  └── tests/           (unit + integration)
```

### Stable (v1.0)

Same structure + plugin SDK + registry API client + CI tools.

---

## Test Strategy

| Phase | Tests | Type |
|-------|-------|------|
| Alpha | 100+ | Unit + integration + mock PM |
| Beta | 300+ | + E2E in Docker (3 distros) |
| Stable | 500+ | + fuzz + performance + upgrade |

### Mock strategy for PM testing

```bash
# tests/mocks/pm.sh
pm_install() {
    local pkg="$1"
    echo "[MOCK] install $pkg"
    HCC_MOCK_INSTALLED+=("$pkg")
    return 0
}
pm_remove() {
    local pkg="$1"
    echo "[MOCK] remove $pkg"
    return 0
}
```

---

## Release Timeline

| Version | Phase | Focus | Audience |
|---------|-------|-------|----------|
| v0.10 | Alpha | Multi-distro, manifest v1, rollback v1 | Contributors |
| v0.12 | Alpha | Community registry, preview | Contributors |
| v0.15 | Alpha | Reliability, tests 100+ | Early testers |
| v0.18 | Beta | Profile switching, plugin v1 | Power users |
| v0.22 | Beta | Update engine, localization | Power users |
| v0.25 | Beta | Nix/Distrobox, tests 300+ | Power users |
| v1.0 | Stable | Guardrails, safety, mass distro | All users |

---

## Immediate Next Steps (v0.10)

1. Refactor `lib/package/map.sh` → support per-distro blocks in TOML
2. Add `ID_LIKE` support to `desktop_package_is_supported()`
3. Fill Debian/Fedora package maps for top 20 Hyprland packages
4. Define `hcc.manifest` v1 spec
5. Write `hcc manifest validate` command
6. Add pre-install compatibility report (`hcc doctor` enhancements)
7. Upgrade tests from smoke to substantive (mocked PM)
