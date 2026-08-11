#!/usr/bin/env bash

HCC_PM=""
HCC_AUR_HELPER=""
HCC_DISTRO_ID=""
HCC_DISTRO_ID_LIKE=""

pm_detect() {
    pm_detect_distro

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

pm_detect_distro() {
    [[ -f /etc/os-release ]] || return 0
    local id id_like
    id="$(. /etc/os-release; printf '%s' "${ID:-}")"
    id_like="$(. /etc/os-release; printf '%s' "${ID_LIKE:-}")"
    HCC_DISTRO_ID="$id"
    HCC_DISTRO_ID_LIKE="$id_like"
}

# Match an id against the current distro id, its ID_LIKE chain,
# or an explicit package-manager name.
pm_distro_matches() {
    local want="$1"
    local pm_name

    [[ "$want" == "$HCC_DISTRO_ID" ]] && return 0

    local w
    for w in $HCC_DISTRO_ID_LIKE; do
        [[ "$want" == "$w" ]] && return 0
    done

    # Allow matching by package manager name (e.g. apt, dnf, pacman)
    pm_name="$HCC_DISTRO_ID"
    case "$pm_name" in
        arch|endeavouros|cachyos|manjaro) pm_name="arch" ;;
        debian|ubuntu|mint|pop) pm_name="debian" ;;
        fedora) pm_name="fedora" ;;
        opensuse*) pm_name="opensuse" ;;
        alpine) pm_name="alpine" ;;
        void) pm_name="void" ;;
    esac
    [[ "$want" == "$pm_name" || "$want" == "$HCC_PM" ]]
}

pm_has_flatpak() {
    [[ "${HCC_HAS_FLATPAK:-false}" == true ]]
}
