
# 🎮 Hyprland Control Center (HCC)

> **Cài đặt và quản lý desktop Hyprland — tự động, an toàn, dễ dàng.**
>
> Dành cho người dùng Arch Linux, EndeavourOS, CachyOS.

---

## HCC là gì?

HCC là công cụ **cài đặt desktop Hyprland** chỉ với **một câu lệnh**.

Bạn không cần phải tự cài từng gói, tự clone từng repo config, tự copy từng file. HCC làm hết cho bạn:

- Tự động cài tất cả packages (PACMAN + AUR)
- Clone config files vào đúng chỗ
- Tự động rollback nếu có lỗi
- Backup config cũ trước khi cài mới
- Phát hiện file conflict trước khi ghi đè
- Cho phép chọn/chuyển đổi giữa nhiều bộ desktop

---

## Bắt đầu nhanh

### 1. Yêu cầu

| Thứ | Ghi chú |
|---|---|
| 💻 Arch Linux / EndeavourOS / CachyOS | HCC chạy trên các hệ thống Arch-based |
| 🌐 Internet | Cần tải packages và config |
| 🔐 Sudo | HCC cần quyền root để cài packages |

### 2. Cài đặt HCC

```bash
# Cách 1 — Một lệnh duy nhất (khuyên dùng)
bash <(curl -s https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh)

# Cách 2 — Clone thủ công
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center && bash install.sh
```

Sau khi cài:

```bash
hcc doctor          # Kiểm tra hệ thống
hcc desktop list    # Xem danh sách desktop có sẵn
```

### 3. Cài desktop

```bash
# Từ registry (có sẵn trong HCC)
hcc desktop install mailong2401

# Từ GitHub URL (bất kỳ repo nào có package.conf)
hcc desktop install https://github.com/end-4/dots-hyprland

# Từ thư mục local
hcc desktop install ./desktops/end-4
```

### 4. Sau khi cài

```bash
hcc profile list        # Xem các profile đã cài
hcc profile status      # Xem profile đang dùng
hcc session list        # Xem danh sách session
hcc session switch      # Menu tương tác chuyển session (tự động backup + restore)
```

### 5. Chuyển đổi desktop

Mỗi desktop được cài vào thư mục riêng biệt:
```
~/.config/hcc/sessions/mailong2401/root/
~/.config/hcc/sessions/end-4/root/
```

Khi chọn session, HCC chỉ thay symlink từ `$HOME` → session root. Desktop cũ vẫn còn nguyên, không mất dữ liệu.

```bash
hcc session switch      # TUI: chọn session, HCC tự deploy symlink
```

Để chọn ngay tại màn hình login (SDDM/GDM):
```bash
sudo hcc session setup-login
# Sau đó logout, chọn "HCC - <tên>" trên màn hình login
```

---

## Các lệnh chính

| Lệnh | Mô tả | Ví dụ |
|---|---|---|
| `hcc doctor` | Kiểm tra sức khỏe hệ thống | `hcc doctor` |
| `hcc desktop list` | Xem danh sách desktop có sẵn | `hcc desktop list` |
| `hcc desktop install <tên\|url\|dir>` | Xem trước + cài desktop | `hcc desktop install end-4` |
| `hcc profile list` | Xem các profile đã cài | `hcc profile list` |
| `hcc profile status` | Xem profile đang dùng | `hcc profile status` |
| `hcc profile switch <id>` | Chuyển active profile | `hcc profile switch mailong2401` |
| `hcc session list` | Xem danh sách session | `hcc session list` |
| `hcc session switch` | TUI chuyển session (tự động restore) | `hcc session switch` |
| `hcc session setup-login` | Tạo login entries cho SDDM/GDM | `sudo hcc session setup-login` |
| `hcc backup` | Backup config hiện tại | `hcc backup` |
| `hcc restore [id]` | Khôi phục từ bản backup | `hcc restore` |
| `hcc theme list` | Xem themes có sẵn | `hcc theme list` |
| `hcc plugins` | Xem plugins có sẵn | `hcc plugins` |
| `hcc help` | Xem trợ giúp | `hcc help` |

---

## Conflict Detection

Khi install desktop thứ 2, HCC tự động kiểm tra file nào sắp bị ghi đè:

```
Detected 3 existing file(s) that will be overwritten:
  Overwrite     /home/user/.config/hypr/hyprland.conf
  Overwrite     /home/user/.config/kitty/kitty.conf
  Repo exists   /home/user/.config/end-4-dots
```

Bạn có thể cancel hoặc tiếp tục.

---

## Desktop packages có sẵn

| Tên | Tác giả | Mô tả | Packages |
|---|---|---|---|
| `mailong2401` | Mailong2401 | Hyprland + Quickshell + Kitty + Fish | 17 PACMAN + 7 AUR |
| `end-4` | end-4 | illogical-impulse: Quickshell widgets, AI, Material Design | 76 PACMAN + 10 AUR |

---

## Tự tạo desktop package

Tạo repo với cấu trúc:

```
repo/
├── hcc.manifest          ← HCC_MANIFEST_VERSION=1, ID, NAME, TYPE=desktop-profile, AUTHOR
└── package.conf          ← PACMAN_PACKAGES, AUR_PACKAGES, GIT_REPOSITORIES, COPY_ITEMS
    └── payload/
        └── .config/...
```

Sau đó chia sẻ link:

```bash
hcc desktop install https://github.com/<bạn>/<repo>
```

Xem `desktops/mailong2401/package.conf` làm mẫu.

---

## Cấu trúc dự án

```
Hyprland-Control-Center/
├── bin/hcc              # Lệnh chính
├── install.sh           # Script cài đặt 1 lệnh
├── desktops/            # Desktop packages (registry.conf + package.conf)
├── lib/                 # Core framework
├── services/            # Service layer
├── operations/          # Atomic commands
├── modules/             # CLI modules
├── plugins/             # Plugins
├── themes/              # Themes
└── tests/               # Test suite
```

---

## FAQ

### "Tôi không biết gì về Linux, có dùng được không?"

Có. HCC được thiết kế để bạn chỉ cần gõ **một lệnh duy nhất**. 
Tuy nhiên bạn cần máy đã cài sẵn **Arch Linux** và tài khoản có quyền `sudo`.

### "Cài nhiều desktop có bị xung đột không?"

HCC sẽ **cảnh báo** nếu file sắp bị ghi đè. Bạn có thể chọn cancel hoặc tiếp tục.

### "Chuyển đổi giữa các desktop đã cài?"

Dùng session switch để chuyển cả config:
```bash
hcc session switch      # Menu tương tác
```
HCC tự động undeploy session cũ + deploy session mới (chỉ thay symlink, không mất dữ liệu).

Hoặc chọn ngay từ màn hình login:
```bash
sudo hcc session setup-login
# Logout → chọn "HCC - <tên>" trên SDDM/GDM
```

Mỗi desktop nằm trong thư mục riêng, hoàn toàn độc lập, không ghi đè lên nhau.

### "Cài xong không thích, có gỡ được không?"

```bash
hcc desktop uninstall <tên>   # Gỡ desktop + rollback config
hcc session remove <tên>      # Xoá session khỏi HCC
```

### "Muốn chia sẻ desktop package của tôi?"

Tạo GitHub repo với `package.conf`, `hcc.manifest` và `payload/`. 
Sau đó chia sẻ link:
```bash
hcc desktop install https://github.com/<bạn>/<repo>
```

---

## Phát triển

```bash
git clone https://github.com/laosifu/Hyprland-Control-Center.git
cd Hyprland-Control-Center
bash tests/run_all.sh      # Chạy unit tests
bash tests/run_cli_tests.sh # Chạy CLI tests
```

---

## Giấy phép

GPL-3.0
