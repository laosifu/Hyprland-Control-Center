#!/usr/bin/env bash

HCC_PM=""
HCC_AUR_HELPER=""

pm_detect() {
    if command -v pacman &>/dev/null; then
        HCC_PM="pacman"
        if command -v yay &>/dev/null; then
            HCC_AUR_HELPER="yay"
        elif command -v paru &>/dev/null; then
            HCC_AUR_HELPER="paru"
        elif command -v trizen &>/dev/null; then
            HCC_AUR_HELPER="trizen"
        fi
    elif command -v apt &>/dev/null; then
        HCC_PM="apt"
    elif command -v dnf &>/dev/null; then
        HCC_PM="dnf"
    elif command -v zypper &>/dev/null; then
        HCC_PM="zypper"
    elif command -v nix &>/dev/null; then
        HCC_PM="nix"
    elif command -v xbps-install &>/dev/null; then
        HCC_PM="xbps"
    elif command -v emerge &>/dev/null; then
        HCC_PM="portage"
    elif command -v apk &>/dev/null; then
        HCC_PM="apk"
    elif command -v flatpak &>/dev/null; then
        HCC_PM="flatpak"
    fi

    if command -v flatpak &>/dev/null; then
        HCC_HAS_FLATPAK=true
    fi

    [[ -n "$HCC_PM" ]]
}

pm_has_flatpak() {
    [[ "${HCC_HAS_FLATPAK:-false}" == true ]]
}
