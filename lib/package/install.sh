#!/usr/bin/env bash

__pm_install_batch() {
    local pm="$1"
    shift
    [[ $# -eq 0 ]] && return 0

    case "$pm" in
        pacman)
            privilege_require_root_unless_dry_run || return 1
            operation_run sudo pacman -S --needed "$@"
            ;;
        apt)
            privilege_require_root_unless_dry_run || return 1
            operation_run sudo apt install -y "$@"
            ;;
        dnf)
            privilege_require_root_unless_dry_run || return 1
            operation_run sudo dnf install -y "$@"
            ;;
        zypper)
            privilege_require_root_unless_dry_run || return 1
            operation_run sudo zypper install -y "$@"
            ;;
        nix)
            local pkg
            for pkg in "$@"; do
                operation_run nix profile install "nixpkgs#$pkg"
            done
            ;;
        xbps)
            privilege_require_root_unless_dry_run || return 1
            operation_run sudo xbps-install -y "$@"
            ;;
        portage)
            privilege_require_root_unless_dry_run || return 1
            operation_run sudo emerge "$@"
            ;;
        apk)
            privilege_require_root_unless_dry_run || return 1
            operation_run sudo apk add "$@"
            ;;
    esac
}

pm_install() {
    [[ -n "$HCC_PM" ]] || pm_detect || { print_error "No package manager detected"; return 1; }

    local to_install=()
    local pkg mapped

    for pkg in "$@"; do
        mapped="$(pm_map_name "$pkg")"

        if pm_installed "$pkg"; then
            print_info "Already installed: $pkg"
            continue
        fi

        to_install+=("$mapped")
    done

    [[ ${#to_install[@]} -eq 0 ]] && return 0

    print_info "Installing (${HCC_PM}): ${to_install[*]}"
    __pm_install_batch "$HCC_PM" "${to_install[@]}"
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

pm_install_all() {
    pm_install "$@"
}
