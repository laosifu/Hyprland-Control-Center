self_update_dispatch() {
    local current_version="$VERSION"
    local latest_commit
    local latest_version
    local current_commit=""
    local install_type="source"
    local project_root="$PROJECT_ROOT"
    local gh_api="https://api.github.com/repos/laosifu/Hyprland-Control-Center"

    if command -v pacman &>/dev/null && pacman -Qi hcc-bin &>/dev/null 2>&1; then
        install_type="aur"
    elif command -v pacman &>/dev/null && pacman -Qi hcc-git &>/dev/null 2>&1; then
        install_type="aur-git"
    elif [[ -d "$project_root/.git" ]]; then
        install_type="source-git"
    fi

    print_info "Kiem tra cap nhat tren GitHub..."
    echo "  Hien tai: v$current_version ($install_type)"

    latest_commit="$(curl -sL "$gh_api/commits/main" 2>/dev/null | grep -m1 '"sha"' | cut -d'"' -f4)"
    latest_version="$(curl -sL "$gh_api/releases/latest" 2>/dev/null | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')"

    if [[ -z "$latest_commit" ]]; then
        print_warning "Khong the kiem tra tu GitHub"
        echo "  Hay thu lai sau hoac kiem tra tai:"
        echo "  https://github.com/laosifu/Hyprland-Control-Center"
        return 1
    fi

    if [[ -d "$project_root/.git" ]]; then
        current_commit="$(git -C "$project_root" rev-parse HEAD 2>/dev/null || true)"
    elif [[ -f "$project_root/.hcc-commit" ]]; then
        current_commit="$(cat "$project_root/.hcc-commit" 2>/dev/null || true)"
    fi

    if [[ -n "$current_commit" ]]; then
        echo "  Commit hien tai:  ${current_commit:0:12}"
        echo "  Commit moi nhat:  ${latest_commit:0:12}"

        if [[ "$current_commit" == "$latest_commit" ]]; then
            print_success "HCC da la ban moi nhat!"
            return 0
        fi

        echo
        print_info "Co commit moi tren GitHub (main) — se cap nhat cac thay doi tinh nang."
        echo
    else
        echo "  Moi nhat: v$latest_version"

        if [[ "$current_version" == "$latest_version" ]]; then
            print_success "HCC da la phien ban moi nhat!"
            return 0
        fi

        echo
        print_info "Co phien ban moi: v$current_version → v$latest_version"
        echo
    fi

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
        source-git)
            echo "  Cap nhat bang: git pull"
            read -rp "  Cap nhat ngay? [y/N] " confirm
            if [[ "$confirm" =~ ^[yY]$ ]]; then
                (cd "$project_root" && git pull)
                print_success "Da cap nhat. Chay lai hcc de dung ban moi."
            fi
            ;;
        source)
            echo "  Cap nhat bang: tai lai tu GitHub (main branch)"
            read -rp "  Cap nhat ngay? [y/N] " confirm
            if [[ "$confirm" =~ ^[yY]$ ]]; then
                local tmp_dir
                tmp_dir="$(mktemp -d)"
                local tarball_url="https://github.com/laosifu/Hyprland-Control-Center/archive/refs/heads/main.tar.gz"
                if curl -fsSL "$tarball_url" -o "$tmp_dir/hcc.tar.gz"; then
                    tar -xzf "$tmp_dir/hcc.tar.gz" -C "$tmp_dir"
                    local src_dir
                    src_dir="$(find "$tmp_dir" -maxdepth 1 -type d -name 'Hyprland-Control-Center-*' | head -n1)"
                    if [[ -n "$src_dir" ]]; then
                        cp -a "$src_dir"/. "$project_root"/
                        echo "$latest_commit" > "$project_root/.hcc-commit"
                        print_success "Da cap nhat len commit ${latest_commit:0:12}."
                        echo "  Chay lai hcc de dung ban moi."
                    else
                        print_error "Giai nen that bai."
                    fi
                else
                    print_error "Tai tarball that bai."
                fi
                rm -rf "$tmp_dir"
            fi
            ;;
    esac
}
