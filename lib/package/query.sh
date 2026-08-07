#!/usr/bin/env bash

pm_installed() {
    local pkg="$1"
    local mapped

    [[ -n "$HCC_PM" ]] || pm_detect || return 1
    mapped="$(pm_map_name "$pkg")"

    case "$HCC_PM" in
        pacman)
            pacman -Qi "$mapped" &>/dev/null
            ;;
        apt)
            dpkg -l "$mapped" &>/dev/null 2>&1
            ;;
        dnf|zypper)
            rpm -q "$mapped" &>/dev/null 2>&1
            ;;
        nix)
            nix profile list 2>/dev/null | grep -q "$mapped"
            ;;
        xbps)
            xbps-query "$mapped" &>/dev/null 2>&1
            ;;
        portage)
            equery list "$mapped" &>/dev/null 2>&1
            ;;
        apk)
            apk info "$mapped" &>/dev/null 2>&1
            ;;
        flatpak)
            flatpak info "$mapped" &>/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

pm_available() {
    local pkg="$1"
    local mapped
    mapped="$(pm_map_name "$pkg")"

    case "$HCC_PM" in
        pacman)
            pacman -Si "$mapped" &>/dev/null 2>&1
            ;;
        apt)
            apt-cache show "$mapped" &>/dev/null 2>&1
            ;;
        dnf)
            dnf info "$mapped" &>/dev/null 2>&1
            ;;
        zypper)
            zypper info "$mapped" &>/dev/null 2>&1
            ;;
        nix)
            nix search "nixpkgs#$mapped" &>/dev/null 2>&1
            ;;
        flatpak)
            flatpak search "$mapped" &>/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}
