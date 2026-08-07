# Hyprland Control Center (HCC)

> **Install and manage Hyprland desktops — automated, safe, and easy.**
>
> **Supports:** Arch Linux · EndeavourOS · CachyOS · (9 package managers, multi-distro)

<p align="center">
  <a href="https://github.com/laosifu/Hyprland-Control-Center/actions"><img src="https://github.com/laosifu/Hyprland-Control-Center/actions/workflows/test.yml/badge.svg" alt="CI"></a>
  <a href="https://aur.archlinux.org/packages/hcc-bin"><img src="https://img.shields.io/aur/version/hcc-bin" alt="AUR"></a>
  <a href="https://github.com/laosifu/Hyprland-Control-Center/releases"><img src="https://img.shields.io/github/v/release/laosifu/Hyprland-Control-Center" alt="Release"></a>
  <a href="https://github.com/laosifu/Hyprland-Control-Center/blob/main/LICENSE"><img src="https://img.shields.io/github/license/laosifu/Hyprland-Control-Center" alt="License"></a>
</p>

---

## What is HCC?

HCC installs any Hyprland desktop with **a single command**. No need to manually install packages, clone config repos, or copy files — HCC handles everything:

- **Package management** across 9 managers (pacman, apt, dnf, zypper, nix, xbps, portage, apk, flatpak) + 4 AUR helpers
- **Config deployment** — clones from GitHub, copies to exact locations
- **URL install** — auto-detects packages from any GitHub repo
- **AI integration** — uses Google Gemini to analyze repos and generate configs
- **Rollback on failure** — transaction stack ensures clean undo
- **Pre-install backup** — timestamped snapshots of existing configs
- **Conflict detection** — warns before overwriting
- **Profile switching** — between multiple installed desktops
- **TOML config** — cross-platform, safe, easy to edit
- **Community registry** — discover and share desktop profiles

---

## Quick Start

### From AUR (recommended for Arch Linux)

```bash
yay -S hcc-bin
hcc doctor                       # Verify installation
hcc desktop list                 # Browse available desktops
hcc desktop install mailong2401  # Install a desktop
```

### From source (any distro)

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
bash hcc doctor
```

### One-liner installer

```bash
bash <(curl -s https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh)
```

---

## Usage

### Installing a desktop

```bash
# From the built-in registry
hcc desktop install mailong2401
hcc desktop install end-4

# From any GitHub URL
hcc desktop install https://github.com/end-4/dots-hyprland

# From a local directory
hcc desktop install ~/Downloads/my-hyprland-setup
```

HCC shows a preview before installing: packages, files, conflicts. Confirm with `y`.

### Super command (one-shot)

```bash
hcc get end-4
```

Auto-installs HCC (if missing) → installs desktop → sets up login screen.

### After installation

```bash
hcc profile list        # View installed profiles
hcc profile status      # View active profile
hcc profile switch <id> # Switch active profile

sudo hcc session setup-login  # Enable login screen entry
```

### Update / Remove

```bash
hcc desktop update <id>       # Pull latest source and re-apply
hcc desktop uninstall <id>    # Remove with full rollback
```

### Create your own desktop package

```bash
hcc desktop init ~/my-desktop   # Interactive wizard
```

### Share with the community

```bash
hcc desktop submit my-desktop   # Guide to submit PR
```

### Search the community registry

```bash
hcc desktop search minimal
hcc desktop search hyprland
```

---

## CLI Command Reference (27 commands)

### System

| Command | Description |
|---|---|
| `hcc doctor` | System health check (OS, RAM, CPU, GPU, DM) |
| `hcc inventory` | Detailed component inventory |
| `hcc cleanup` | Scan cache sizes (pacman, yay, cargo, pip, npm) |
| `hcc inspect <path\|url>` | Inspect a repository manifest |

### Desktop Management

| Command | Description |
|---|---|
| `hcc desktop list` | List available desktops |
| `hcc desktop search <keyword>` | Search community registry |
| `hcc desktop install <name\|url\|dir>` | Preview and install desktop |
| `hcc desktop update <id>` | Update an installed desktop |
| `hcc desktop uninstall <id>` | Remove desktop + rollback |
| `hcc desktop init [dir]` | Interactive wizard to create a desktop profile |
| `hcc desktop submit <id>` | Guide to submit desktop to community registry |

### Super Command

| Command | Description |
|---|---|
| `hcc get <profile>` | Install HCC + desktop + setup login (one-shot) |

### Profile Management

| Command | Description |
|---|---|
| `hcc profile list` | View installed profiles |
| `hcc profile status` | View active profile |
| `hcc profile switch <id>` | Switch active profile |

### Session

| Command | Description |
|---|---|
| `hcc session setup-login` | Create DM login entries |

### Backup & Restore

| Command | Description |
|---|---|
| `hcc backup` | Backup current config |
| `hcc restore [id]` | Restore from backup |

### Theme & Plugin

| Command | Description |
|---|---|
| `hcc theme list` | List available themes |
| `hcc theme install <name>` | Install a theme |
| `hcc theme uninstall <name>` | Uninstall a theme |
| `hcc plugins` | List available plugins |
| `hcc plugin install <name>` | Install a plugin |
| `hcc plugin uninstall <name>` | Uninstall a plugin |

### AI Integration

| Command | Description |
|---|---|
| `hcc ai setup` | Configure Google Gemini API key |
| `hcc ai status` | Check AI configuration |
| `hcc ai remove-key` | Remove API key |

### Other

| Command | Description |
|---|---|
| `hcc help` | Show help |
| `hcc --version` | Show version |

---

## Available Desktop Packages

| ID | Author | Packages | AUR | Description |
|---|---|---|---|---|
| `mailong2401` | Mailong2401 | 16 | 7 | Hyprland + Quickshell cartoon-shell + Kitty + Fish |
| `end-4` | end-4 | 75 | 10 | illogical-impulse: Quickshell widgets, AI, Material Design |

Each desktop includes `package.toml`, `package.conf` (legacy), `payload/` (configs), and `hooks/`.

---

## Key Features

### Package Abstraction Layer (9 PMs)

HCC auto-detects the correct package manager:

| Manager | Distro | Command |
|---|---|---|
| pacman | Arch / EndeavourOS / CachyOS | `sudo pacman -S` |
| apt | Debian / Ubuntu / Mint | `sudo apt install` |
| dnf | Fedora / RHEL | `sudo dnf install` |
| zypper | openSUSE | `sudo zypper install` |
| nix | NixOS | `nix profile install` |
| xbps | Void | `sudo xbps-install` |
| portage | Gentoo | `sudo emerge` |
| apk | Alpine | `sudo apk add` |
| flatpak | All | `flatpak install` |

AUR helpers: `yay`, `paru`, `trizen`, `pamac`. Cross-distro name mapping (e.g. `fd` → `fd-find` on Debian).

### TOML Config

Desktop profiles use the TOML format — cross-platform, safe, and backward compatible:

```toml
name = "end-4 illogical-impulse"
id = "end-4"
version = "1.0"
author = "end-4"

[packages]
required = ["hyprland", "kitty", "fish", "starship"]
aur = ["quickshell-git", "matugen-bin"]

[git]
repositories = [{ url = "https://github.com/end-4/dots-hyprland.git", path = "~/.config/end-4-dots" }]

[config]
payload_root = "."
install_path = "~"

[hooks]
post_install = "hooks/post-install.sh"
```

### AI Auto-Detection

When installing from URL without `package.conf`, HCC uses **Google Gemini 2.0 Flash** to analyze the repo and generate a complete config.

```bash
hcc ai setup           # Configure API key (free tier)
hcc desktop install https://github.com/...  # AI handles it
```

### Safe by Default

- **Pre-install backup** — timestamped snapshot
- **Conflict detection** — warns before overwriting
- **Transaction rollback** — automatic undo on failure
- **Preview mode** — see everything before confirming

### Community Registry

Discover desktops from the community:

```bash
hcc desktop search minimal
hcc desktop search hyprland
```

Submit your own via `hcc desktop submit <id>`.

### Display Manager Support

Auto-detects SDDM, GDM, LightDM, greetd. Installs session entries automatically.

---

## Creating a Desktop Package

Create a GitHub repo with this structure:

```
repo/
├── hcc.manifest          ← HCC_MANIFEST_VERSION=1, ID, NAME, TYPE=desktop-profile
├── package.toml          ← packages, git, config, hooks
└── payload/
    └── .config/
        ├── hypr/
        ├── kitty/
        └── ...
```

Or use the interactive wizard:

```bash
hcc desktop init ~/my-desktop
```

Share your desktop with the community via `hcc desktop submit`.

---

## Installation Methods

### 1. AUR (recommended for Arch)

```bash
yay -S hcc-bin           # stable release
# or
yay -S hcc-git           # development version
```

### 2. One-liner installer

```bash
bash <(curl -s https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh)
```

### 3. Manual clone

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
bash install.sh
```

### 4. Run without installing

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
alias hcc='$PWD/bin/hcc'
hcc doctor
```

---

## Requirements

| Requirement | Notes |
|---|---|
| Linux | Arch / EndeavourOS / CachyOS (other distros supported experimentally) |
| Internet | Required for packages and configs |
| Sudo access | For package installation |
| AUR helper | `yay`, `paru`, `trizen`, or `pamac` (auto-detected) |

---

## Development

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center

# Run all 36 tests
bash tests/run_all.sh
bash tests/run_cli_tests.sh
```

### Project structure

```
Hyprland-Control-Center/
├── bin/hcc              # CLI entry point
├── install.sh           # One-command installer
├── VERSION              # Version file
├── desktops/            # Desktop packages (registry + package.toml/conf)
├── lib/                 # Core framework
│   ├── package/         # Package abstraction (9 PMs)
│   ├── config/          # TOML parser + config reader
│   ├── display_manager/ # DM detection + session management
│   ├── planners/        # Plan generators
│   ├── renderers/       # Output formatters
│   └── launchers/       # Session launcher for DM
├── services/            # Service layer (7 services)
├── operations/          # Atomic command wrappers
├── modules/             # CLI command implementations (19 modules)
├── plugins/             # Plugin system
├── themes/              # Theme system
├── handlers/            # Handler wrappers
├── dist/aur/            # AUR PKGBUILDs (hcc-bin, hcc-git)
├── docs/                # Documentation
└── tests/               # Test suite (36 tests)
```

---

## Architecture

```
CLI → Module → Planner → Action DSL → Executor → Dispatcher → Services → Operations → Shell Commands
```

Full architecture in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## FAQ

### "I don't know anything about Linux, can I use this?"

Yes. HCC is designed so you only need **one command**. You need Arch Linux (or similar) and sudo access.

### "Can I install multiple desktops?"

Yes. HCC warns about file conflicts. Each profile is independent.

### "How do I switch between desktops?"

```bash
hcc profile list
hcc profile switch <id>
```

### "Can I uninstall a desktop?"

```bash
hcc desktop uninstall <name>
```

### "Does HCC support other distros?"

The package layer supports 9 PMs. Tested on Arch. Fedora/Ubuntu/NixOS support under development.

### "Can I share my desktop package?"

Create a repo with `package.toml`, `hcc.manifest`, and `payload/`. Share the link:

```bash
hcc desktop install https://github.com/<you>/<repo>
```

Then submit via `hcc desktop submit <id>`.

### "Does the AI integration cost money?"

Google Gemini has a **free tier** (60 requests/minute). Get your key at https://aistudio.google.com/apikey

### "Where is my data stored?"

| Data | Location |
|---|---|
| Config | `~/.config/hcc/` |
| Installed profiles | `~/.local/share/hcc/profiles/` |
| Backups | `~/.local/share/hcc/backups/` |
| Cache | `~/.cache/hcc/` |

---

## Version History

| Version | Date | Highlights |
|---|---|---|
| v0.8.0 | 2026-07-28 | AUR packages, community registry, super command, CI/CD, release |
| v0.7.0 | 2026-07-25 | Flatpak, batch install, DM abstraction, init wizard |
| v0.6.0 | 2026-07-24 | TOML config, Python parser, Gemini AI integration |
| v0.5.0 | 2026-07-23 | Profile system, session launcher |
| v0.4.0 | 2026-07-22 | Desktop registry, URL install, manifest |
| v0.3.0 | 2026-07-22 | Plugin/theme system, CLI expansion |
| v0.2.0 | 2026-07-21 | Backup/restore, uninstall, test framework |
| v0.1.0 | 2026-07-20 | Initial: CLI, planner, executor, basic install |

---

## License

GPL-3.0
