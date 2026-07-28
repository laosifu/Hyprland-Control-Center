#!/usr/bin/env bash

pm_remove() {
    local pkg

    [[ -n "$HCC_PM" ]] || pm_detect || { print_error "No package manager detected"; return 1; }

    for pkg in "$@"; do
        local mapped
        mapped="$(pm_map_name "$pkg")"

        pm_installed "$pkg" || { print_info "Not installed, skipping: $pkg"; continue; }

        print_info "Removing: $pkg"

        case "$HCC_PM" in
            pacman)
                operation_run sudo pacman -Rns "$mapped"
                ;;
            apt)
                operation_run sudo apt remove -y "$mapped"
                ;;
            dnf)
                operation_run sudo dnf remove -y "$mapped"
                ;;
            zypper)
                operation_run sudo zypper remove -y "$mapped"
                ;;
            nix)
                operation_run nix profile remove "$mapped"
                ;;
            xbps)
                operation_run sudo xbps-remove -y "$mapped"
                ;;
            portage)
                operation_run sudo emerge -C "$mapped"
                ;;
            apk)
                operation_run sudo apk del "$mapped"
                ;;
            flatpak)
                operation_run flatpak uninstall -y "$mapped"
                ;;
        esac
    done
}
