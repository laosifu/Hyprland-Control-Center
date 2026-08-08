# Hyprland Control Center (HCC)

> **Cài đặt và quản lý desktop Hyprland — tự động, an toàn, dễ dàng.**
>
> **Hỗ trợ:** Arch Linux · EndeavourOS · CachyOS · (9 trình quản lý gói, đa distro)

<p align="center">
  <a href="https://github.com/laosifu/Hyprland-Control-Center/actions"><img src="https://github.com/laosifu/Hyprland-Control-Center/actions/workflows/test.yml/badge.svg" alt="CI"></a>
  <a href="https://aur.archlinux.org/packages/hcc-bin"><img src="https://img.shields.io/aur/version/hcc-bin" alt="AUR"></a>
  <a href="https://github.com/laosifu/Hyprland-Control-Center/releases"><img src="https://img.shields.io/github/v/release/laosifu/Hyprland-Control-Center" alt="Release"></a>
  <a href="https://github.com/laosifu/Hyprland-Control-Center/blob/main/LICENSE"><img src="https://img.shields.io/github/license/laosifu/Hyprland-Control-Center" alt="License"></a>
</p>

---

## HCC là gì?

HCC là công cụ cài đặt desktop Hyprland chỉ với **một câu lệnh**. Không cần tự cài gói, tự clone repo, tự copy file — HCC làm tất cả:

- **Quản lý gói** qua 9 trình quản lý (pacman, apt, dnf, zypper, nix, xbps, portage, apk, flatpak) + 4 AUR helpers
- **Triển khai config** — clone từ GitHub, copy đúng vị trí
- **Cài từ URL** — tự động phát hiện packages từ bất kỳ GitHub repo nào
- **AI Integration** — dùng Google Gemini để phân tích repo và sinh cấu hình
- **Rollback tự động** — transaction stack đảm bảo undo sạch nếu lỗi
- **Backup trước khi cài** — snapshot có timestamp
- **Phát hiện xung đột** — cảnh báo trước khi ghi đè
- **Chuyển đổi profile** — giữa nhiều desktop đã cài
- **TOML config** — cross-platform, an toàn, dễ chỉnh sửa
- **Community registry** — khám phá và chia sẻ desktop profiles

---

## Bắt đầu nhanh

### Từ AUR (khuyên dùng cho Arch Linux)

```bash
yay -S hcc-bin
hcc doctor                       # Kiểm tra cài đặt
hcc desktop list                 # Xem danh sách desktop
hcc desktop install mailong2401  # Cài desktop
```

### Từ source (bất kỳ distro nào)

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
bash hcc doctor
```

### Một lệnh duy nhất

```bash
bash <(curl -s https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh)
```

---

## Sử dụng

### Cài desktop

```bash
# Từ registry có sẵn
hcc desktop install mailong2401
hcc desktop install end-4

# Từ GitHub URL bất kỳ
hcc desktop install https://github.com/end-4/dots-hyprland

# Từ thư mục local
hcc desktop install ~/Downloads/my-hyprland-setup
```

HCC hiển thị preview trước khi cài: packages, files, conflicts. Xác nhận với `y`.

### Super command (một chạm)

```bash
hcc get end-4
```

Tự động cài HCC (nếu thiếu) → cài desktop → thiết lập màn hình login.

### Sau khi cài

```bash
hcc profile list        # Xem các profile đã cài
hcc profile status      # Xem profile đang dùng
hcc profile switch <id> # Chuyển active profile

sudo hcc session setup-login  # Kích hoạt màn hình login
```

### Cập nhật / Gỡ

```bash
hcc desktop update <id>       # Kéo source mới và cài lại
hcc desktop uninstall <id>    # Gỡ với rollback đầy đủ
```

### Tự tạo desktop package

```bash
hcc desktop init ~/my-desktop   # Wizard tương tác
```

### Chia sẻ với cộng đồng

```bash
hcc desktop submit my-desktop   # Hướng dẫn submit PR
```

### Tìm kiếm community registry

```bash
hcc desktop search minimal
hcc desktop search hyprland
```

---

## Danh sách lệnh CLI (27 lệnh)

### Hệ thống

| Lệnh | Mô tả |
|---|---|
| `hcc doctor` | Kiểm tra sức khỏe hệ thống (OS, RAM, CPU, GPU, DM) |
| `hcc inventory` | Kiểm tra component chi tiết |
| `hcc cleanup` | Quét dung lượng cache (pacman, yay, cargo, pip, npm) |
| `hcc inspect <path\|url>` | Inspect repository manifest |

### Desktop Management

| Lệnh | Mô tả |
|---|---|
| `hcc desktop list` | Xem danh sách desktop có sẵn |
| `hcc desktop search <keyword>` | Tìm kiếm community registry |
| `hcc desktop install <name\|url\|dir>` | Xem trước + cài desktop |
| `hcc desktop update <id>` | Cập nhật desktop đã cài |
| `hcc desktop uninstall <id>` | Gỡ desktop + rollback |
| `hcc desktop init [dir]` | Wizard tạo desktop profile |
| `hcc desktop submit <id>` | Hướng dẫn submit lên community |

### Super Command

| Lệnh | Mô tả |
|---|---|
| `hcc get <profile>` | Cài HCC + desktop + setup login (một lần) |

### Profile Management

| Lệnh | Mô tả |
|---|---|
| `hcc profile list` | Xem các profile đã cài |
| `hcc profile status` | Xem profile đang dùng |
| `hcc profile switch <id>` | Chuyển active profile |

### Session

| Lệnh | Mô tả |
|---|---|
| `hcc session setup-login` | Tạo login entries cho DM |

### Backup & Restore

| Lệnh | Mô tả |
|---|---|
| `hcc backup` | Backup config hiện tại |
| `hcc restore [id]` | Khôi phục từ backup |

### Theme & Plugin

| Lệnh | Mô tả |
|---|---|
| `hcc theme list` | Xem themes có sẵn |
| `hcc theme install <name>` | Cài theme |
| `hcc theme uninstall <name>` | Gỡ theme |
| `hcc plugins` | Xem plugins có sẵn |
| `hcc plugin install <name>` | Cài plugin |
| `hcc plugin uninstall <name>` | Gỡ plugin |

### AI Integration

| Lệnh | Mô tả |
|---|---|
| `hcc ai setup` | Cấu hình Google Gemini API key |
| `hcc ai status` | Kiểm tra trạng thái AI |
| `hcc ai remove-key` | Xoá API key |

### Khác

| Lệnh | Mô tả |
|---|---|
| `hcc help` | Xem trợ giúp |
| `hcc --version` | Xem phiên bản |

---

## Desktop packages có sẵn

| ID | Tác giả | Packages | AUR | Mô tả |
|---|---|---|---|---|
| `mailong2401` | Mailong2401 | 16 | 7 | Hyprland + Quickshell cartoon-shell + Kitty + Fish |
| `end-4` | end-4 | 75 | 10 | illogical-impulse: Quickshell widgets, AI, Material Design |

Mỗi desktop gồm `package.toml`, `package.conf` (tương thích ngược), `payload/` (configs), và `hooks/`.

---

## Tính năng chính

### Package Abstraction (9 PMs)

HCC tự động phát hiện và dùng đúng package manager:

| Manager | Distro | Lệnh |
|---|---|---|
| pacman | Arch / EndeavourOS / CachyOS | `sudo pacman -S` |
| apt | Debian / Ubuntu / Mint | `sudo apt install` |
| dnf | Fedora / RHEL | `sudo dnf install` |
| zypper | openSUSE | `sudo zypper install` |
| nix | NixOS | `nix profile install` |
| xbps | Void | `sudo xbps-install` |
| portage | Gentoo | `sudo emerge` |
| apk | Alpine | `sudo apk add` |
| flatpak | Tất cả | `flatpak install` |

AUR helpers: `yay`, `paru`, `trizen`, `pamac`. Tự động map tên gói giữa các distro.

### TOML Config

Desktop profiles dùng định dạng TOML — cross-platform, an toàn, tương thích ngược:

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

Khi cài từ URL không có `package.conf`, HCC dùng **Google Gemini 2.0 Flash** để phân tích repo và sinh cấu hình hoàn chỉnh.

```bash
hcc ai setup           # Cấu hình API key (miễn phí)
hcc desktop install https://github.com/...  # AI tự xử lý
```

### An toàn

- **Backup trước khi cài** — snapshot có timestamp
- **Phát hiện xung đột** — cảnh báo trước khi ghi đè
- **Rollback tự động** — undo khi gặp lỗi
- **Preview** — xem tất cả trước khi xác nhận

### Community Registry

Khám phá desktop từ cộng đồng:

```bash
hcc desktop search minimal
hcc desktop search hyprland
```

Gửi desktop của bạn qua `hcc desktop submit <id>`.

### Display Manager

Tự động phát hiện SDDM, GDM, LightDM, greetd. Cài session entries tự động. Session launcher tự được cài vào `/usr/lib/hcc/session-launcher` (sudo nếu cần) và khởi động Hyprland qua `start-hyprland` (fallback `/usr/bin/Hyprland`).

---

## Tạo desktop package

Tạo GitHub repo với cấu trúc:

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

Hoặc dùng wizard:

```bash
hcc desktop init ~/my-desktop
```

Chia sẻ với cộng đồng qua `hcc desktop submit`.

---

## Phương pháp cài đặt

### 1. AUR (khuyên dùng cho Arch)

```bash
yay -S hcc-bin           # Bản stable
# hoặc
yay -S hcc-git           # Bản phát triển
```

### 2. Một lệnh

```bash
bash <(curl -s https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh)
```

### 3. Clone thủ công

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
bash install.sh
```

### 4. Chạy trực tiếp (không cần cài)

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
alias hcc='$PWD/bin/hcc'
hcc doctor
```

---

## Yêu cầu

| Yêu cầu | Ghi chú |
|---|---|
| Linux | Arch / EndeavourOS / CachyOS (distro khác đang phát triển) |
| Internet | Cần để tải packages và configs |
| Quyền sudo | Để cài packages |
| AUR helper | `yay`, `paru`, `trizen`, hoặc `pamac` (tự động phát hiện) |

---

## Phát triển

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center

# Chạy tất cả 36 tests
bash tests/run_all.sh
bash tests/run_cli_tests.sh
```

### Cấu trúc dự án

```
Hyprland-Control-Center/
├── bin/hcc              # CLI entry point
├── install.sh           # One-command installer
├── VERSION              # File phiên bản
├── desktops/            # Desktop packages (registry + package.toml/conf)
├── lib/                 # Core framework
│   ├── package/         # Package abstraction (9 PMs)
│   ├── config/          # TOML parser + config reader
│   ├── display_manager/ # DM detection + session management
│   ├── planners/        # Plan generators
│   ├── renderers/       # Output formatters
│   └── launchers/       # Session launcher cho DM
├── services/            # Service layer (7 services)
├── operations/          # Atomic command wrappers
├── modules/             # CLI command implementations (19 modules)
├── plugins/             # Plugin system
├── themes/              # Theme system
├── handlers/            # Handler wrappers
├── dist/aur/            # AUR PKGBUILDs (hcc-bin, hcc-git)
├── docs/                # Tài liệu
└── tests/               # Test suite (36 tests)
```

---

## Kiến trúc

```
CLI → Module → Planner → Action DSL → Executor → Dispatcher → Services → Operations → Shell Commands
```

Xem chi tiết tại [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## FAQ

### "Tôi không biết gì về Linux, có dùng được không?"

Có. HCC được thiết kế để bạn chỉ cần **một câu lệnh**. Cần máy Arch Linux và quyền sudo.

### "Cài nhiều desktop có bị xung đột không?"

HCC cảnh báo nếu file sắp bị ghi đè. Mỗi profile độc lập.

### "Làm sao chuyển đổi giữa các desktop?"

```bash
hcc profile list
hcc profile switch <id>
```

### "Gỡ desktop được không?"

```bash
hcc desktop uninstall <tên>
```

### "HCC có hỗ trợ distro khác không?"

Package layer hỗ trợ 9 PMs. Đã test trên Arch. Fedora/Ubuntu/NixOS đang phát triển.

### "Muốn chia sẻ desktop package của tôi?"

Tạo repo với `package.toml`, `hcc.manifest`, `payload/`. Chia sẻ link:

```bash
hcc desktop install https://github.com/<bạn>/<repo>
```

Sau đó submit qua `hcc desktop submit <id>`.

### "AI Integration có tốn phí không?"

Google Gemini có **free tier** (60 requests/phút). Lấy API key tại https://aistudio.google.com/apikey

### "Dữ liệu của tôi ở đâu?"

| Dữ liệu | Vị trí |
|---|---|
| Config | `~/.config/hcc/` |
| Profile đã cài | `~/.local/share/hcc/profiles/` |
| Backups | `~/.local/share/hcc/backups/` |
| Cache | `~/.cache/hcc/` |

---

## Lịch sử phiên bản

| Phiên bản | Ngày | Nổi bật |
|---|---|---|
| v0.9.2 | 2026-08-08 | Fix login/session: launcher đọc đúng file active, tự cài session-launcher khi tạo login entry, uninstall 16 items + `0=all`, sudo gom 1 lần, dùng `start-hyprland` |
| v0.9.0 | 2026-07-28 | TUI default, self-update, doctor recommendations, config diff, desktop export, AI fallback, Flatpak GUI apps, 10 community profiles, session sudo fix, README rewrite |
| v0.8.0 | 2026-07-28 | AUR packages, community registry, super command, CI/CD |
| v0.7.0 | 2026-07-25 | Flatpak, batch install, DM abstraction, init wizard |
| v0.6.0 | 2026-07-24 | TOML config, Python parser, Gemini AI |
| v0.5.0 | 2026-07-23 | Profile system, session launcher |
| v0.4.0 | 2026-07-22 | Desktop registry, URL install |
| v0.3.0 | 2026-07-22 | Plugin/theme system |
| v0.2.0 | 2026-07-21 | Backup/restore, test framework |
| v0.1.0 | 2026-07-20 | Initial release |

---

## License

GPL-3.0
