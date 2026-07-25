#!/usr/bin/env bash

pm_install() {
    local pkg

    [[ -n "$HCC_PM" ]] || pm_detect || { print_error "No package manager detected"; return 1; }

    for pkg in "$@"; do
        local mapped
        mapped="$(pm_map_name "$pkg")"

        if pm_installed "$pkg"; then
            print_info "Already installed: $pkg"
            continue
        fi

        print_info "Installing: $mapped ($HCC_PM)"

        case "$HCC_PM" in
            pacman)
                privilege_require_root_unless_dry_run || return 1
                operation_run sudo pacman -S --needed "$mapped"
                ;;
            apt)
                privilege_require_root_unless_dry_run || return 1
                operation_run sudo apt install -y "$mapped"
                ;;
            dnf)
                privilege_require_root_unless_dry_run || return 1
                operation_run sudo dnf install -y "$mapped"
                ;;
            zypper)
                privilege_require_root_unless_dry_run || return 1
                operation_run sudo zypper install -y "$mapped"
                ;;
            nix)
                operation_run nix profile install "nixpkgs#$mapped"
                ;;
            xbps)
                privilege_require_root_unless_dry_run || return 1
                operation_run sudo xbps-install -y "$mapped"
                ;;
            portage)
                privilege_require_root_unless_dry_run || return 1
                operation_run sudo emerge "$mapped"
                ;;
            apk)
                privilege_require_root_unless_dry_run || return 1
                operation_run sudo apk add "$mapped"
                ;;
        esac
    done
}

pm_install_aur() {
    local pkg="$1"

    [[ -n "$HCC_PM" ]] || pm_detect || true
    [[ -n "$HCC_AUR_HELPER" ]] || {
        print_warning "No AUR helper found, skipping: $pkg"
        print_info "Install manually or set HCC_AUR_HELPER=yay|paru"
        return 0
    }

    if pm_installed "$pkg"; then
        print_info "AUR already installed: $pkg"
        return 0
    fi

    print_info "Installing AUR: $pkg ($HCC_AUR_HELPER)"

    case "$HCC_AUR_HELPER" in
        yay)
            operation_run yay -S --needed --noconfirm "$pkg"
            ;;
        paru)
            operation_run paru -S --needed --noconfirm "$pkg"
            ;;
        trizen)
            operation_run trizen -S --needed --noconfirm "$pkg"
            ;;
        pamac)
            operation_run pamac install --no-confirm "$pkg"
            ;;
    esac
}
