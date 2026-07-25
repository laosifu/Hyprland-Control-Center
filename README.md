# Hyprland Control Center (HCC)

> **Cài đặt và quản lý desktop Hyprland — tự động, an toàn, dễ dàng.**
>
> Dành cho Arch Linux, EndeavourOS, CachyOS.

---

## HCC là gì?

HCC là công cụ **cài đặt desktop Hyprland** chỉ với **một câu lệnh**.

Bạn không cần phải tự cài từng gói, tự clone từng repo config, tự copy từng file. HCC làm hết cho bạn:

- **Tự động cài tất cả packages** (PACMAN + AUR) trên 8 trình quản lý gói (pacman, apt, dnf, zypper, nix, xbps, portage, apk)
- **Clone config files** vào đúng chỗ từ GitHub
- **Hỗ trợ cài từ URL** — tự động phát hiện packages từ `install.sh`, `.config/`, `.gitmodules`
- **AI Integration** — dùng Google Gemini để phân tích repo và sinh cấu hình
- **Tự động rollback** nếu có lỗi (transaction stack)
- **Backup config cũ** trước khi cài mới
- **Phát hiện file conflict** trước khi ghi đè
- **Chuyển đổi giữa nhiều desktop** đã cài (profile system)
- **Theme & Plugin system** — mở rộng chức năng
- **TOML config** — định dạng cross-platform thay thế shell script

---

## Installation

### Yêu cầu

| Thứ | Ghi chú |
|---|---|
| 💻 Arch Linux / EndeavourOS / CachyOS | Hỗ trợ thêm distro khác đang phát triển |
| 🌐 Internet | Cần tải packages và config |
| 🔐 Sudo | HCC cần quyền root để cài packages |
| 📦 AUR helper | `yay` hoặc `paru` (tự động phát hiện) |

### Cách 1 — Một lệnh duy nhất (khuyên dùng)

```bash
bash <(curl -s https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh)
```

Script sẽ tự động:
1. Kiểm tra OS
2. Kiểm tra dependencies (bash, git, sudo, AUR helper)
3. Clone HCC vào `~/.local/share/hcc`
4. Thêm `~/.local/bin` vào PATH
5. Tạo symlink `hcc`
6. Cài session launcher cho màn hình login

Sau khi cài, **mở terminal mới** hoặc chạy:
```bash
source ~/.bashrc   # hoặc .zshrc / config.fish
```

### Cách 2 — Clone thủ công

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
bash install.sh
```

### Cách 3 — Chạy trực tiếp (không cần cài)

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
alias hcc='$PWD/bin/hcc'
hcc doctor
```

### Kiểm tra sau khi cài

```bash
hcc doctor          # Kiểm tra hệ thống
hcc desktop list    # Xem danh sách desktop có sẵn
hcc --version       # Xem phiên bản
```

---

## Cài desktop

### Từ registry (có sẵn trong HCC)

```bash
hcc desktop install mailong2401
hcc desktop install end-4
```

### Từ GitHub URL (bất kỳ repo nào)

```bash
hcc desktop install https://github.com/end-4/dots-hyprland
```

HCC sẽ:
1. Clone repo
2. Tự động phát hiện packages (quét `.config/`, `install.sh`, `.gitmodules`)
3. Nếu không tự động được → dùng AI (Gemini) để phân tích
4. Nếu AI không có → hiển thị menu tương tác để bạn tự cấu hình

### Từ thư mục local

```bash
hcc desktop install ./desktops/end-4
hcc desktop install ~/Downloads/my-hyprland-setup
```

### Xem trước khi cài

Trước khi cài, HCC hiển thị:
- Tên, phiên bản, tác giả
- Danh sách packages sẽ cài
- File conflict (nếu có)
- Yêu cầu xác nhận `[y/N]`

---

## Sau khi cài

```bash
hcc profile list        # Xem các profile đã cài
hcc profile status      # Xem profile đang dùng
hcc profile switch <id> # Chuyển đổi active profile
```

Từ màn hình login (SDDM/GDM):
```bash
sudo hcc session setup-login
# Logout → chọn "HCC" trên màn hình login
```

Gỡ desktop:
```bash
hcc desktop uninstall <id>
```

---

## CLI Commands

### System

| Lệnh | Mô tả | Ví dụ |
|---|---|---|
| `hcc doctor` | Kiểm tra sức khỏe hệ thống (OS, RAM, CPU, GPU, DM) | `hcc doctor` |
| `hcc inventory` | Kiểm tra component chi tiết | `hcc inventory` |
| `hcc cleanup` | Quét dung lượng cache (pacman, yay, cargo, pip, npm) | `hcc cleanup` |
| `hcc inspect <path\|url>` | Inspect repository manifest | `hcc inspect ./desktops/end-4` |

### Desktop Management

| Lệnh | Mô tả | Ví dụ |
|---|---|---|
| `hcc desktop list` | Xem danh sách desktop có sẵn | `hcc desktop list` |
| `hcc desktop search <keyword>` | Tìm kiếm community registry | `hcc desktop search minimal` |
| `hcc desktop install <name\|url\|dir>` | Xem trước + cài desktop | `hcc desktop install end-4` |
| `hcc desktop uninstall <id>` | Gỡ desktop + rollback | `hcc desktop uninstall end-4` |

### Profile Management

| Lệnh | Mô tả | Ví dụ |
|---|---|---|
| `hcc profile list` | Xem các profile đã cài | `hcc profile list` |
| `hcc profile status` | Xem profile đang dùng | `hcc profile status` |
| `hcc profile switch <id>` | Chuyển active profile | `hcc profile switch mailong2401` |

### Session

| Lệnh | Mô tả | Ví dụ |
|---|---|---|
| `hcc session setup-login` | Tạo login entries cho SDDM/GDM | `sudo hcc session setup-login` |

### Backup & Restore

| Lệnh | Mô tả | Ví dụ |
|---|---|---|
| `hcc backup` | Backup config hiện tại | `hcc backup` |
| `hcc restore [id]` | Khôi phục từ bản backup | `hcc restore` |

### Theme & Plugin

| Lệnh | Mô tả | Ví dụ |
|---|---|---|
| `hcc theme list` | Xem themes có sẵn | `hcc theme list` |
| `hcc theme install <name>` | Cài theme | `hcc theme install example` |
| `hcc theme uninstall <name>` | Gỡ theme | `hcc theme uninstall example` |
| `hcc plugins` | Xem plugins có sẵn | `hcc plugins` |
| `hcc plugin install <name>` | Cài plugin | `hcc plugin install example` |
| `hcc plugin uninstall <name>` | Gỡ plugin | `hcc plugin uninstall example` |

### AI Integration

| Lệnh | Mô tả | Ví dụ |
|---|---|---|
| `hcc ai setup` | Cấu hình Google Gemini API key | `hcc ai setup` |
| `hcc ai status` | Kiểm tra trạng thái AI | `hcc ai status` |
| `hcc ai remove-key` | Xoá API key | `hcc ai remove-key` |

### Other

| Lệnh | Mô tả |
|---|---|
| `hcc help` | Xem trợ giúp |
| `hcc --version` | Xem phiên bản |

---

## Desktop packages có sẵn

| Tên | Tác giả | Mô tả | Packages |
|---|---|---|---|
| `mailong2401` | Mailong2401 | Hyprland + Quickshell cartoon-shell + Kitty + Fish | 16 PACMAN + 7 AUR |
| `end-4` | end-4 | illogical-impulse: Quickshell widgets, AI, Material Design | 75 PACMAN + 10 AUR |

Mỗi desktop đều có:
- `package.conf` (định dạng shell, tương thích ngược)
- `package.toml` (định dạng mới, cross-platform)
- `payload/` chứa config files
- `hooks/` chứa script tuỳ chỉnh (post-install, v.v.)

---

## Key Features

### Package Abstraction Layer

HCC tự động phát hiện và dùng đúng package manager:

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

AUR helpers cũng tự động phát hiện: `yay`, `paru`, `trizen`, `pamac`.

Package names tự động map giữa các distro (ví dụ: `fd` → `fd-find` trên Debian).

### TOML Config

Desktop profile chuyển sang định dạng TOML:

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

Hỗ trợ song song với `package.conf` cũ.

### AI Auto-Detection

Khi cài từ URL không có `package.conf`, HCC có thể dùng **Google Gemini 2.0 Flash** để:
1. Đọc cấu trúc repo
2. Đọc README, install scripts
3. Sinh `package.conf` hoàn chỉnh

```bash
hcc ai setup           # Cấu hình API key (miễn phí)
hcc desktop install https://github.com/...  # AI tự động xử lý
```

### Safe by Default

- **Backup** trước khi cài (timestamped snapshot)
- **Conflict detection** — cảnh báo file sắp bị ghi đè
- **Transaction rollback** — nếu lỗi ở bước 5, tự động undo 4 bước trước
- **Dry-run mode** — xem trước mà không chạy thật
- **Pre-install summary** — xem tất cả packages/files trước khi xác nhận

### Theme & Plugin System

HCC có hệ thống theme và plugin mở rộng:
- Theme: thay đổi giao diện Hyprland (colors, fonts, wallpapers)
- Plugin: mở rộng tính năng (widgets, scripts, integrations)
- Mỗi theme/plugin có `requirements.conf` để kiểm tra dependencies

---

## Tự tạo desktop package

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

Sau đó chia sẻ link:

```bash
hcc desktop install https://github.com/<bạn>/<repo>
```

Xem `desktops/mailong2401/` hoặc `desktops/end-4/` làm mẫu.

---

## Development

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center

# Chạy tất cả tests
bash tests/run_all.sh

# Chỉ chạy unit tests
bash tests/run_all.sh

# Chạy CLI tests
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
│   ├── package/         # Package abstraction layer (detect, map, install, remove, query)
│   ├── config/          # TOML parser + config reader
│   ├── planners/        # Plan generators (package, aur, git, copy)
│   ├── renderers/       # Output formatters
│   └── launchers/       # Session launcher for DM
├── services/            # Service layer
├── operations/          # Atomic command wrappers
├── modules/             # CLI command implementations
├── handlers/            # Handler wrappers
├── plugins/             # Plugin system
├── themes/              # Theme system
└── tests/               # Test suite (36 tests)
```

---

## FAQ

### "Tôi không biết gì về Linux, có dùng được không?"

Có. HCC được thiết kế để bạn chỉ cần gõ **một lệnh duy nhất**.
Tuy nhiên bạn cần máy đã cài sẵn **Arch Linux** và tài khoản có quyền `sudo`.

### "Cài nhiều desktop có bị xung đột không?"

HCC sẽ **cảnh báo** nếu file sắp bị ghi đè. Bạn có thể chọn cancel hoặc tiếp tục.

### "Chuyển đổi giữa các desktop đã cài?"

```bash
hcc profile list           # Xem các profile đã cài
hcc profile switch <id>    # Chuyển active profile
```

Sau đó chọn từ màn hình login:
```bash
sudo hcc session setup-login
# Logout → chọn "HCC" trên SDDM/GDM
```

### "Cài xong không thích, có gỡ được không?"

```bash
hcc desktop uninstall <tên>   # Gỡ desktop + rollback config
```

### "HCC có hỗ trợ distro khác không?"

Package abstraction layer đã hỗ trợ 8 trình quản lý gói. Tuy nhiên HCC mới chỉ được test trên Arch Linux và các distro Arch-based. Fedora/Ubuntu/NixOS support đang phát triển.

### "Muốn chia sẻ desktop package của tôi?"

Tạo GitHub repo với `package.toml`, `hcc.manifest` và `payload/`.
Sau đó chia sẻ link:
```bash
hcc desktop install https://github.com/<bạn>/<repo>
```

### "AI Integration có tốn phí không?"

Google Gemini có **free tier** (60 requests/phút, đủ dùng). Chỉ cần tạo API key tại https://aistudio.google.com/apikey

---

## License

GPL-3.0
