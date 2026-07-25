# HCC Architecture & Roadmap

> Mục tiêu: **distro-agnostic**, modular, có thể scale — từ Arch Linux sang mọi Linux distro.

---

## 1. Vision

**Hyprland Control Center** trở thành tool chuẩn để **cài đặt và quản lý Hyprland desktop** trên bất kỳ Linux distro nào:

- 1 lệnh → có Hyprland desktop hoàn chỉnh (packages + configs)
- Chọn giữa nhiều desktop profile từ cộng đồng
- An toàn: backup trước, rollback nếu lỗi
- Tích hợp login screen (SDDM/GDM/LightDM/greetd)

---

## 2. Architecture Overview

```
                    ┌──────────────────┐
                    │   hcc CLI (Bash) │  Entry point
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
    ┌─────────────────┐ ┌──────────┐ ┌──────────────┐
    │ Package Manager │ │ Desktop  │ │ Display      │
    │ Abstraction     │ │ Registry │ │ Manager      │
    │ Layer           │ │ (git)    │ │ Integration   │
    └────────┬────────┘ └──────────┘ └──────┬───────┘
             ▼                               ▼
    ┌─────────────────┐             ┌──────────────────┐
    │ pacman (Arch)   │             │ SDDM / GDM       │
    │ apt (Debian)    │             │ LightDM / greetd │
    │ dnf (Fedora)    │             └──────────────────┘
    │ zypper (openSUSE)│
    │ nix (NixOS)     │
    │ flatpak (any)   │
    └─────────────────┘

    ┌──────────────────────────────────────────────┐
    │              Desktop Profile                  │
    │  package.toml + payload/ + hooks/             │
    │  (distro-agnostic format)                     │
    └──────────────────────────────────────────────┘
```

### 2.1 Package Manager Abstraction Layer

Layer quan trọng nhất — biến HCC từ Arch-only thành universal.

```
lib/
  package/
    detect.sh     — auto-detect: pacman / apt / dnf / nix / flatpak
    install.sh    — pm_install <packages> → dispatch đúng backend
    remove.sh     — pm_remove <packages>
    query.sh      — pm_installed <package> → true/false
    map.sh        — map package names giữa các distro
```

```bash
# ví dụ pm_install
pm_install() {
  case "$HCC_PM" in
    pacman) sudo pacman -S --needed "$@" ;;
    apt)    sudo apt install -y "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    nix)    nix profile install "nixpkgs#$1" ;;  # từng cái 1
    flatpak) flatpak install -y flathub "$@" ;;
  esac
}
```

**Package name mapping** — distro khác nhau gọi package khác tên:

```bash
# lib/package/map.sh
pm_map_name() {
  case "${HCC_PM}:$1" in
    apt:hyprland)      echo "hyprland" ;;           # giống tên
    apt:webkit2gtk)    echo "libwebkit2gtk-4.1-dev" ;;
    dnf:webkit2gtk)    echo "webkit2gtk4.1-devel" ;;
    pacman:webkit2gtk) echo "webkit2gtk-4.1" ;;
    *)                 echo "$1" ;;                  # fallback
  esac
}
```

### 2.2 Desktop Profile Format (TOML)

Chuyển từ `package.conf` (shell) sang `package.toml` (cross-platform):

```toml
name = "End-4 Dots"
id = "end-4"
version = "1.1.0"
author = "end-4"
description = "Minimal modern Hyprland desktop"
license = "MIT"

[packages]
required = ["hyprland", "kitty", "waybar", "wofi", "hyprpaper"]
optional = ["cava", "mpv", "thunar", "btop"]

[config]
payload_root = "."
install_path = "~"

[display_manager]
entry_name = "HCC - End-4"
desktop_names = "Hyprland"

[hooks]
post_install = "hooks/post-install.sh"

[metadata]
tags = ["hyprland", "minimal", "modern"]
screenshot = "https://example.com/screenshot.png"
```

**Tại sao TOML thay vì shell:**
- Parse được bằng mọi ngôn ngữ (Rust, Go, Python, Bash via `toml2sh`)
- Không inject code, an toàn hơn
- Dễ viết tooling (validate, edit GUI)
- Cộng đồng dễ đóng góp hơn

### 2.3 Desktop Registry

```
desktops/
  end-4/
    package.toml
    payload/.config/hypr/hyprland.conf
    payload/.config/kitty/kitty.conf
    hooks/post-install.sh
  mailong2401/
    package.toml
    payload/...
  registry.conf                     ← local registry index
```

Cơ chế hoạt động:

1. `hcc desktop list` → đọc `desktops/*/package.toml` + community registry
2. `hcc desktop install end-4` → parse TOML, generate plan, execute, register profile
3. `hcc desktop remove end-4` → xóa files từ plan, xóa profile registry

### 2.4 Display Manager Integration

```bash
lib/
  display_manager/
    detect.sh       — SDDM / GDM / LightDM / greetd
    install_entry.sh— tạo .desktop entry đúng format cho từng DM
    remove_entry.sh — xóa .desktop entry
```

Mỗi DM có format `.desktop` khác nhau:

| DM | Path | Notes |
|---|---|---|
| SDDM | `/usr/share/wayland-sessions/` | Chuẩn FreeDesktop |
| GDM | `/usr/share/wayland-sessions/` | Giống SDDM |
| LightDM | `/usr/share/xsessions/` + `/usr/share/wayland-sessions/` | Cả X11 và Wayland |
| greetd | Config-dependent | Thường cấu hình trong `/etc/greetd/config.toml` |

### 2.5 Session Launcher (Enhanced)

```bash
/usr/lib/hcc/session-launcher

Flow:
1. Init logging → /tmp/hcc-launcher.log
2. Detect environment (XDG_RUNTIME_DIR, DBUS, etc.)
3. Read active profile (~/.config/hcc/session-active)
4. Deploy profile configs (copy từ profile registry → $HOME)
5. Exec Hyprland (hoặc start-hyprland -- ...)
```

---

## 3. Directory Layout (Future)

```
~/.local/share/hcc/
├── profiles/                 ← profile registry (installed)
│   ├── end-4/profile.conf
│   ├── mailong2401/profile.conf
│   └── active               ← active profile ID
├── desktops/                 ← external cloned repos
│   └── <user>-<repo>/
│       ├── package.toml
│       └── payload/
├── backups/                  ← snapshot trước khi install
│   └── <timestamp>-<profile>/
├── logs/                     ← install logs
└── cache/                    ← community registry cache

~/.config/hcc/
├── hcc.conf                  ← user config
├── session-active            ← active profile cho session launcher
└── ai.conf                   ← Gemini API key (optional)
```

---

## 4. Roadmap

### Phase 1 — Foundation (2 tháng)

**Mục tiêu:** HCC chạy được trên Arch, Fedora, Ubuntu + cơ bản.

| Task | Priority | Ghi chú |
|---|---|---|
| Package abstraction layer | P0 | `lib/package/detect.sh`, `install.sh`, `remove.sh`, `query.sh` |
| Package name mapping | P0 | Map hyprland, kitty, waybar, v.v. giữa Arch/Fedora/Debian |
| TOML config format | P0 | Parse TOML → plan actions (dùng `toml2sh` hoặc `jq`) |
| Migrate existing profiles | P0 | `end-4`, `mailong2401` → `package.toml` |
| Add 5 new desktop profiles | P1 | Tuyển từ cộng đồng Hyprland |
| CI test 3 distros | P1 | GitHub Actions: Arch, Fedora, Ubuntu |
| Flatpak support | P2 | `flatpak install` cho non-native packages |

### Phase 2 — Experience (2 tháng)

**Mục tiêu:** Trải nghiệm người dùng mượt, an toàn, dễ tiếp cận.

| Task | Priority | Ghi chú |
|---|---|---|
| `hcc get <profile>` | P0 | Super command: detect → install → apply → done |
| Installation wizard | P1 | TUI hoặc confirmation steps cho người mới |
| Enhanced session launcher | P1 | Env setup, logging, crash recovery |
| Display manager abstraction | P1 | Detect SDDM/GDM/LightDM/greetd + đúng format |
| GitHub Releases + AUR | P1 | `hcc-bin`, `hcc-git` |
| English documentation | P1 | README, ARCHITECTURE, CONTRIBUTING |
| error handling audit | P2 | Replace `|| true` với proper error messages |

### Phase 3 — Community (2-4 tháng)

**Mục tiêu:** Ecosystem mở, cộng đồng đóng góp.

| Task | Priority | Ghi chú |
|---|---|---|
| Community registry | P0 | GitHub-based, PR để thêm profile |
| `hcc desktop submit` | P1 | Auto fork + PR lên community repo |
| Plugin system activation | P1 | Đã có skeleton, kích hoạt và document |
| Profile template | P2 | `hcc desktop init` tạo profile mới |
| GitHub Discussions | P2 | Support + showcase |
| Flatpak release | P2 | Cho distro không phải Arch |

### Phase 4 — Future (6+ tháng)

**Mục tiêu:** Scale lên tầm cao mới.

| Task | Priority | Ghi chú |
|---|---|---|
| Core rewrite (Rust/Go) | Optional | Nếu Bash > 10k LOC, khó maintain |
| GUI (GTK4/Qt6) | Optional | Cho non-CLI users |
| Nix flake | P2 | Cho NixOS |
| `hcc doctor` nâng cao | P1 | GPU driver check, Hyprland version, port conflicts |
| Profile dependencies graph | P2 | Visual tree of what gets installed |
| AUR helper abstraction | P1 | `yay` / `paru` / `pamac` auto-detect |

---

## 5. Design Principles

1. **Distro-agnostic first** — mọi feature phải chạy được trên ≥2 distro trước khi merge
2. **Safety by default** — backup trước khi ghi đè, dry-run luôn available
3. **Modular** — mỗi layer độc lập, có thể swap backend (package manager, DM, registry)
4. **Simple over clever** — Bash cho CLI layer, chỉ rewrite nếu performance/security yêu cầu
5. **Community-driven** — profile format phải dễ đóng góp (TOML > shell, git-based registry)
6. **Progressive complexity** — 1 lệnh cho newbie, nhiều option cho power user

---

## 6. Current State vs Target

| Dimension | Current (v0.6.1) | Target (v2.0) |
|---|---|---|
| Distro support | Arch-only | Arch, Fedora, Ubuntu, openSUSE, NixOS |
| Package format | `/etc/pacman.conf` | `lib/package/*.sh` abstraction |
| Config format | Shell (`package.conf`) | TOML (`package.toml`) |
| Desktop profiles | 2 | 15+ (community) |
| Display managers | SDDM (X11) | SDDM, GDM, LightDM, greetd |
| Session isolation | Removed | Optional via env vars (không symlinks) |
| Tests | 25 unit (Bash) | 50+ unit + integration (Bash + BATS) |
| CLI language | Vietnamese + English | English (unified) |
| Distribution | Git clone | AUR, GitHub Releases, Homebrew (Linux) |

---

*Last updated: 2026-07-25*
