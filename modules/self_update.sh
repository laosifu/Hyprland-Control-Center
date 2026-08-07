self_update_dispatch() {
    local current_version="$VERSION"
    local latest_version
    local install_type="source"

    if command -v pacman &>/dev/null && pacman -Qi hcc-bin &>/dev/null 2>&1; then
        install_type="aur"
    elif command -v pacman &>/dev/null && pacman -Qi hcc-git &>/dev/null 2>&1; then
        install_type="aur-git"
    fi

    print_info "Kiem tra phien ban moi..."
    echo "  Hien tai: v$current_version ($install_type)"

    latest_version=$(curl -sL "https://api.github.com/repos/laosifu/Hyprland-Control-Center/releases/latest" 2>/dev/null | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')

    if [[ -z "$latest_version" ]]; then
        print_warning "Khong the kiem tra phien ban tu GitHub"
        echo "  Hay thu lai sau hoac kiem tra tai:"
        echo "  https://github.com/laosifu/Hyprland-Control-Center/releases"
        return 1
    fi

    echo "  Moi nhat: v$latest_version"

    if [[ "$current_version" == "$latest_version" ]]; then
        print_success "HCC da la phien ban moi nhat!"
        return 0
    fi

    echo
    print_info "Co phien ban moi: v$current_version → v$latest_version"
    echo

    case "$install_type" in
        aur)
            echo "  Cap nhat bang: yay -S hcc-bin"
            read -rp "  Cap nhat ngay? [y/N] " confirm
            if [[ "$confirm" =~ ^[yY]$ ]]; then
                yay -S hcc-bin
            fi
            ;;
        aur-git)
            echo "  Cap nhat bang: yay -S hcc-git"
            read -rp "  Cap nhat ngay? [y/N] " confirm
            if [[ "$confirm" =~ ^[yY]$ ]]; then
                yay -S hcc-git
            fi
            ;;
        source)
            echo "  Cap nhat bang: git pull"
            local repo_dir
            repo_dir="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
            read -rp "  Cap nhat ngay? [y/N] " confirm
            if [[ "$confirm" =~ ^[yY]$ ]]; then
                (cd "$repo_dir" && git pull)
                print_success "Da cap nhat. Chay lai hcc de dung phien ban moi."
            fi
            ;;
    esac
}
