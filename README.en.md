# Hyprland Control Center (HCC)

> **Install and manage Hyprland desktops — automated, safe, and easy.**
>
> For Arch Linux, EndeavourOS, CachyOS (with multi-distro support in development).

---

## What is HCC?

HCC is a tool that installs Hyprland desktops with **a single command**.

No need to manually install packages, clone config repos, or copy files. HCC handles everything:

- **Automatically installs all packages** (PACMAN + AUR) across 8 package managers (pacman, apt, dnf, zypper, nix, xbps, portage, apk)
- **Clones config files** into the right places from GitHub
- **URL install support** — auto-detects packages from `install.sh`, `.config/`, `.gitmodules`
- **AI Integration** — uses Google Gemini to analyze repos and generate configs
- **Automatic rollback** on failure (transaction stack)
- **Backup existing configs** before installing new ones
- **Conflict detection** before overwriting files
- **Profile switching** between multiple installed desktops
- **Theme & Plugin system** for extensibility
- **TOML config format** — cross-platform, safe, and easy to edit

---

## Installation

### Requirements

| Item | Notes |
|---|---|
| 💻 Arch Linux / EndeavourOS / CachyOS | Other distros supported experimentally |
| 🌐 Internet | Required for packages and configs |
| 🔐 Sudo | HCC needs root for package installation |
| 📦 AUR helper | `yay`, `paru`, `trizen`, or `pamac` (auto-detected) |

### Method 1 — One-liner (recommended)

```bash
bash <(curl -s https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh)
```

The script automatically:
1. Checks OS compatibility
2. Checks dependencies (bash, git, sudo, AUR helper)
3. Clones HCC to `~/.local/share/hcc`
4. Adds `~/.local/bin` to PATH
5. Creates `hcc` symlink
6. Installs session launcher for login screen

After installation, **open a new terminal** or run:
```bash
source ~/.bashrc   # or .zshrc / config.fish
```

### Method 2 — Manual clone

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
bash install.sh
```

### Method 3 — Run without installing

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
alias hcc='$PWD/bin/hcc'
hcc doctor
```

### Verify installation

```bash
hcc doctor          # System health check
hcc desktop list    # List available desktops
hcc --version       # Show version
```

---

## Installing a desktop

### From the built-in registry

```bash
hcc desktop install mailong2401
hcc desktop install end-4
```

### From a GitHub URL (any repo)

```bash
hcc desktop install https://github.com/end-4/dots-hyprland
```

HCC will:
1. Clone the repo
2. Auto-detect packages (scans `.config/`, `install.sh`, `.gitmodules`)
3. If auto-detect fails → use AI (Gemini) to analyze
4. If AI unavailable → interactive menu for manual config

### From a local directory

```bash
hcc desktop install ./desktops/end-4
hcc desktop install ~/Downloads/my-hyprland-setup
```

### Preview before installing

Before installation, HCC shows:
- Desktop name, version, author
- List of packages to install
- File conflicts (if any)
- Requires confirmation `[y/N]`

---

## After installation

```bash
hcc profile list        # View installed profiles
hcc profile status      # View active profile
hcc profile switch <id> # Switch active profile
```

From the login screen (SDDM/GDM):
```bash
sudo hcc session setup-login
# Logout → select "HCC" from login screen
```

Update an installed desktop:
```bash
hcc desktop update <id>
```

Remove a desktop:
```bash
hcc desktop uninstall <id>
```

---

## CLI Commands

### System

| Command | Description | Example |
|---|---|---|
| `hcc doctor` | System health check (OS, RAM, CPU, GPU, DM) | `hcc doctor` |
| `hcc inventory` | Detailed component inventory | `hcc inventory` |
| `hcc cleanup` | Scan cache sizes (pacman, yay, cargo, pip, npm) | `hcc cleanup` |
| `hcc inspect <path\|url>` | Inspect a repository manifest | `hcc inspect ./desktops/end-4` |

### Desktop Management

| Command | Description | Example |
|---|---|---|
| `hcc desktop list` | List available desktops | `hcc desktop list` |
| `hcc desktop search <keyword>` | Search community registry | `hcc desktop search minimal` |
| `hcc desktop install <name\|url\|dir>` | Preview and install desktop | `hcc desktop install end-4` |
| `hcc desktop update <id>` | Update an installed desktop | `hcc desktop update end-4` |
| `hcc desktop uninstall <id>` | Remove desktop + rollback | `hcc desktop uninstall end-4` |

### Profile Management

| Command | Description | Example |
|---|---|---|
| `hcc profile list` | View installed profiles | `hcc profile list` |
| `hcc profile status` | View active profile | `hcc profile status` |
| `hcc profile switch <id>` | Switch active profile | `hcc profile switch mailong2401` |

### Session

| Command | Description | Example |
|---|---|---|
| `hcc session setup-login` | Create DM login entries | `sudo hcc session setup-login` |

### Backup & Restore

| Command | Description | Example |
|---|---|---|
| `hcc backup` | Backup current config | `hcc backup` |
| `hcc restore [id]` | Restore from backup | `hcc restore` |

### Theme & Plugin

| Command | Description | Example |
|---|---|---|
| `hcc theme list` | List available themes | `hcc theme list` |
| `hcc theme install <name>` | Install a theme | `hcc theme install example` |
| `hcc theme uninstall <name>` | Uninstall a theme | `hcc theme uninstall example` |
| `hcc plugins` | List available plugins | `hcc plugins` |
| `hcc plugin install <name>` | Install a plugin | `hcc plugin install example` |
| `hcc plugin uninstall <name>` | Uninstall a plugin | `hcc plugin uninstall example` |

### AI Integration

| Command | Description | Example |
|---|---|---|
| `hcc ai setup` | Configure Google Gemini API key | `hcc ai setup` |
| `hcc ai status` | Check AI configuration | `hcc ai status` |
| `hcc ai remove-key` | Remove API key | `hcc ai remove-key` |

### Other

| Command | Description |
|---|---|
| `hcc help` | Show help |
| `hcc --version` | Show version |

---

## Available Desktop Packages

| ID | Author | Required | AUR | Description |
|---|---|---|---|---|
| `mailong2401` | Mailong2401 | 16 | 7 | Hyprland + Quickshell cartoon-shell + Kitty + Fish |
| `end-4` | end-4 | 75 | 10 | illogical-impulse: Quickshell widgets, AI, Material Design |

Each desktop includes:
- `package.conf` (legacy shell format, backward compatible)
- `package.toml` (new cross-platform format)
- `payload/` with config files
- `hooks/` for custom scripts (post-install, etc.)

---

## Key Features

### Package Abstraction Layer

HCC auto-detects and uses the correct package manager:

```
pacman (Arch)  → sudo pacman -S
apt (Debian)   → sudo apt install
dnf (Fedora)   → sudo dnf install
zypper (openSUSE) → sudo zypper install
nix (NixOS)    → nix profile install
xbps (Void)    → sudo xbps-install
portage (Gentoo) → sudo emerge
apk (Alpine)   → sudo apk add
```

AUR helpers auto-detected: `yay`, `paru`, `trizen`, `pamac`.

Package names are mapped across distros (e.g., `fd` → `fd-find` on Debian).

### TOML Config

Desktop profiles now use the TOML format:

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

Backward compatible with `package.conf`.

### AI Auto-Detection

When installing from a URL without `package.conf`, HCC can use **Google Gemini 2.0 Flash** to:
1. Read the repo structure
2. Read README and install scripts
3. Generate a complete `package.conf`

```bash
hcc ai setup           # Configure API key (free tier)
hcc desktop install https://github.com/...  # AI handles it automatically
```

### Safe by Default

- **Backup** before installing (timestamped snapshot)
- **Conflict detection** — warns about files that will be overwritten
- **Transaction rollback** — if step 5 fails, undo the previous 4 steps
- **Dry-run mode** — preview without executing
- **Pre-install summary** — review all packages/files before confirming

### Display Manager Support

HCC auto-detects your display manager:

| DM | Detection | Session entry path |
|---|---|---|
| SDDM | systemd service | `/usr/share/wayland-sessions/` |
| GDM | systemd service | `/usr/share/wayland-sessions/` |
| LightDM | binary check | `/usr/share/wayland-sessions/` or `/usr/share/xsessions/` |
| greetd | systemd service | `/usr/share/wayland-sessions/` (manual greetd config may be needed) |

### Theme & Plugin System

HCC has an extensible theme and plugin system:
- Theme: change Hyprland appearance (colors, fonts, wallpapers)
- Plugin: extend functionality (widgets, scripts, integrations)
- Each theme/plugin has `requirements.conf` for dependency checking

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

Share the link:

```bash
hcc desktop install https://github.com/<you>/<repo>
```

See `desktops/mailong2401/` or `desktops/end-4/` for examples.

---

## Development

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center

# Run all tests
bash tests/run_all.sh

# Run CLI tests
bash tests/run_cli_tests.sh
```

### Project structure

```
Hyprland-Control-Center/
├── bin/hcc              # CLI entry point
├── install.sh           # One-command installer
├── VERSION              # Version file
├── desktops/            # Desktop packages (registry.conf + package.conf/toml)
├── lib/                 # Core framework
│   ├── package/         # Package abstraction layer
│   ├── config/          # TOML parser + config reader
│   ├── display_manager/ # DM detection + session entry management
│   ├── planners/        # Plan generators
│   ├── renderers/       # Output formatters
│   └── launchers/       # Session launcher for DM
├── services/            # Service layer
├── operations/          # Atomic command wrappers
├── modules/             # CLI command implementations
├── plugins/             # Plugin system
├── themes/              # Theme system
└── tests/               # Test suite (36 tests)
```

---

## FAQ

### "I don't know anything about Linux, can I use this?"

Yes. HCC is designed so you only need to run **one command**. You'll need a machine with **Arch Linux** (or similar) and a `sudo`-enabled account.

### "Can I install multiple desktops?"

Yes. HCC warns about file conflicts. Each desktop install is independent.

### "How do I switch between desktops?"

```bash
hcc profile list           # View installed profiles
hcc profile switch <id>    # Switch active profile
```

### "Can I uninstall a desktop?"

```bash
hcc desktop uninstall <name>   # Remove desktop + rollback config
```

### "Does HCC support other distros?"

The package abstraction layer supports 8 package managers. HCC has been tested on Arch Linux and Arch-based distros. Fedora/Ubuntu/NixOS support is under development.

### "Can I share my own desktop package?"

Create a GitHub repo with `package.toml`, `hcc.manifest` and `payload/`. Share the link:

```bash
hcc desktop install https://github.com/<you>/<repo>
```

### "Does the AI integration cost money?"

Google Gemini has a **free tier** (60 requests/minute). Just create an API key at https://aistudio.google.com/apikey

---

## License

GPL-3.0
