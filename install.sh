#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { printf "${CYAN}%s${NC}\n" "$1"; }
ok()    { printf "${GREEN}[✓] %s${NC}\n" "$1"; }
warn()  { printf "${YELLOW}[!] %s${NC}\n" "$1"; }
fail()  { printf "${RED}[✗] %s${NC}\n" "$1"; exit 1; }

echo
echo "========================================"
echo "  Hyprland Control Center — Installer"
echo "========================================"
echo

#
# 1. Detect OS
#
info "[1/6] Kiểm tra hệ điều hành..."

os_id=""
os_name=""
if [[ -f /etc/os-release ]]; then
    os_id="$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')"
    os_name="$(grep ^NAME= /etc/os-release | cut -d= -f2 | tr -d '"')"
fi

case "$os_id" in
    arch|endeavouros|cachyos)
        ok "Phát hiện: $os_id"
        ;;
    *)
        warn "OS: $os_name ($os_id) — chưa được test chính thức."
        warn "HCC sẽ thử dùng package abstraction layer (hỗ trợ 8 PMs)."
        warn "Nếu gặp lỗi, hãy tạo issue trên GitHub."
        ;;
esac

#
# 2. Check dependencies
#
info "[2/6] Kiểm tra công cụ cần thiết..."

for cmd in bash git sudo; do
    if command -v "$cmd" &>/dev/null; then
        ok "  $cmd"
    else
        fail "Thiếu: $cmd. Hãy cài đặt trước."
    fi
done

if command -v yay &>/dev/null; then
    ok "  yay (AUR helper)"
elif command -v paru &>/dev/null; then
    ok "  paru (AUR helper)"
elif command -v trizen &>/dev/null; then
    ok "  trizen (AUR helper)"
elif command -v pamac &>/dev/null; then
    ok "  pamac (AUR helper)"
else
    warn "  Không tìm thấy AUR helper (yay/paru/trizen/pamac)."
    warn "  AUR packages sẽ không cài được. Chỉ cài PACMAN packages."
fi

#
# 3. Clone/Update repo
#
info "[3/6] Cài đặt HCC..."

install_dir="$HOME/.local/share/hcc"

if [[ -d "$install_dir" ]]; then
    info "  HCC đã có sẵn, đang cập nhật..."
    git -C "$install_dir" pull --ff-only 2>/dev/null || {
        warn "  Không thể cập nhật tự động. Bạn có thể clone lại thủ công."
    }
else
    mkdir -p "$(dirname "$install_dir")"
    git clone https://github.com/laosifu/Hyprland-Control-Center.git "$install_dir"
    ok "  Đã clone HCC vào $install_dir"
fi

#
# 4. Add to PATH
#
info "[4/6] Thêm HCC vào PATH..."

bin_dir="$HOME/.local/bin"
mkdir -p "$bin_dir"

if [[ -f "$bin_dir/hcc" ]]; then
    rm -f "$bin_dir/hcc"
fi
ln -s "$install_dir/bin/hcc" "$bin_dir/hcc"
ok "  Symlink: $bin_dir/hcc → $install_dir/bin/hcc"

shell_config=""
case "${SHELL:-}" in
    */bash) shell_config="$HOME/.bashrc" ;;
    */zsh)  shell_config="$HOME/.zshrc" ;;
    */fish) shell_config="$HOME/.config/fish/config.fish" ;;
esac

if [[ -n "$shell_config" ]] && ! grep -q "\.local/bin" "$shell_config" 2>/dev/null; then
    printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$shell_config"
    ok "  Đã thêm ~/.local/bin vào PATH trong $shell_config"
fi

#
# 5. Initialize config
#
info "[5/6] Khởi tạo cấu hình..."

"$bin_dir/hcc" --version &>/dev/null && ok "  HCC hoạt động!" || fail "  HCC không chạy được."

#
# 5b. Install shell completions
#
completion_installed=false
bash_comp_dir="/usr/share/bash-completion/completions"
fish_comp_dir="$HOME/.config/fish/completions"

if [[ -d "$bash_comp_dir" ]]; then
    if sudo cp "$install_dir/completions/hcc.bash" "$bash_comp_dir/hcc" 2>/dev/null; then
        ok "  Bash completions installed"
        completion_installed=true
    fi
fi

if [[ -d "$fish_comp_dir" ]] || mkdir -p "$fish_comp_dir" 2>/dev/null; then
    if cp "$install_dir/completions/hcc.fish" "$fish_comp_dir/hcc.fish" 2>/dev/null; then
        ok "  Fish completions installed"
        completion_installed=true
    fi
fi

if $completion_installed; then
    ok "  Shell completions installed"
else
    warn "  Không cài được shell completions (thiếu quyền hoặc thư mục)"
fi

#
# 6. Install session launcher (cần root)
#
info "[6/6] Cài đặt session launcher cho màn hình login..."

launcher_src="$install_dir/lib/launchers/session-launcher.sh"
launcher_dst="/usr/lib/hcc/session-launcher"
if sudo mkdir -p /usr/lib/hcc 2>/dev/null && sudo cp "$launcher_src" "$launcher_dst" && sudo chmod +x "$launcher_dst"; then
    ok "  Session launcher installed: $launcher_dst"
else
    warn "  Không cài được session launcher. Chạy sau: sudo hcc session setup-login"
fi

echo
echo "========================================"
echo "  Cài đặt hoàn tất!"
echo "========================================"
echo
echo "  Bước tiếp theo:"
echo
echo "    1. Mở terminal mới (hoặc: source $shell_config)"
echo "    2. Chạy: hcc doctor          ← kiểm tra hệ thống"
echo "    3. Chạy: hcc desktop list    ← xem desktop có sẵn"
echo "    4. Chạy: hcc desktop install <tên>  ← cài desktop"
echo
echo "  Desktop có sẵn:"
echo

if [[ -f "$install_dir/desktops/registry.conf" ]]; then
    source "$install_dir/desktops/registry.conf"
    for id in $DESKTOP_REGISTRY_IDS; do
        var="DESKTOP_REGISTRY_$(echo "$id" | tr '[:lower:]' '[:upper:]' | tr '-' '_')_PATH"
        path="${!var}"
        echo "    • $id"
    done
fi

echo
echo "  Cần giúp đỡ? Mở README.md hoặc tạo issue trên GitHub."
echo
