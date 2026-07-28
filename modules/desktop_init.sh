run_desktop_init() {
    local target_dir="${1:-$PWD}"

    print_header "Desktop Profile Creator"
    echo

    if [[ -f "$target_dir/package.toml" || -f "$target_dir/package.conf" ]]; then
        print_error "Target directory already contains a desktop profile: $target_dir"
        return 1
    fi

    print_info "This wizard will help you create a new HCC desktop profile."
    print_info "Current config will be scanned to auto-detect packages."
    echo

    local name id version author description license
    local scan_config scan_packages scan_git copy_payload

    read -rp "Desktop name: " name
    [[ -z "$name" ]] && name="My Hyprland Desktop"

    local default_id
    default_id="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g; s/[^a-z0-9-]//g')"
    read -rp "ID [$default_id]: " id
    [[ -z "$id" ]] && id="$default_id"

    read -rp "Version [0.1.0]: " version
    [[ -z "$version" ]] && version="0.1.0"

    read -rp "Author: " author
    [[ -z "$author" ]] && author="unknown"

    read -rp "Description: " description

    read -rp "License [MIT]: " license
    [[ -z "$license" ]] && license="MIT"

    echo
    print_info "Scan current ~/.config for auto-detection?"
    read -rp "Scan packages? [Y/n]: " scan_packages
    scan_packages="${scan_packages:-y}"

    read -rp "Scan config dirs for payload? [Y/n]: " scan_config
    scan_config="${scan_config:-y}"

    read -rp "Scan git repos? [Y/n]: " scan_git
    scan_git="${scan_git:-y}"

    read -rp "Copy config files into payload/ (will modify your filesystem)? [y/N]: " copy_payload
    copy_payload="${copy_payload:-n}"

    echo
    print_info "Creating profile: $name ($id)"
    echo

    mkdir -p "$target_dir/payload" "$target_dir/hooks" || return 1

    local pacman_pkgs="" aur_pkgs="" copy_items="" git_repos="" seen_dirs=""

    if [[ "$scan_packages" == y* || "$scan_packages" == Y* ]]; then
        local pkg_out aur_out dirs_out
        pkg_out="$(desktop_external_detect_from_home_config 2>/dev/null || true)"
        aur_out="$(echo "$pkg_out" | sed -n '2p')"
        dirs_out="$(echo "$pkg_out" | sed -n '3p')"
        pacman_pkgs="$(echo "$pkg_out" | head -1)"
        aur_pkgs="$aur_out"
        seen_dirs="$dirs_out"

        if [[ -n "$pacman_pkgs" ]]; then
            print_success "Detected packages: $pacman_pkgs"
        fi
        if [[ -n "$aur_pkgs" ]]; then
            print_success "Detected AUR packages: $aur_pkgs"
        fi
    fi

    if [[ "$scan_config" == y* || "$scan_config" == Y* ]]; then
        local cfg_dir
        for cfg_dir in "$HOME/.config"/*/; do
            [[ -d "$cfg_dir" ]] || continue
            local base
            base="$(basename "$cfg_dir")"

            local found=false
            local d
            for d in $seen_dirs; do [[ "$d" == "$base" ]] && found=true; done
            [[ "$found" == true ]] && continue

            if [[ ! " $seen_dirs " =~ " $base " ]]; then
                seen_dirs="$seen_dirs $base"
            fi
        done

        for cfg_dir in $seen_dirs; do
            if [[ -d "$HOME/.config/$cfg_dir" ]]; then
                copy_items="$copy_items"$'\n'".config/$cfg_dir|~/.config/$cfg_dir"
            fi
        done
    fi

    if [[ "$scan_git" == y* || "$scan_git" == Y* ]]; then
        for cfg_dir in $seen_dirs; do
            local git_path="$HOME/.config/$cfg_dir"
            if [[ -d "$git_path/.git" ]]; then
                local remote
                remote="$(git -C "$git_path" remote get-url origin 2>/dev/null || true)"
                if [[ -n "$remote" ]]; then
                    git_repos="$git_repos"$'\n'"$remote|~/.config/$cfg_dir"
                    print_info "Git repo: $cfg_dir → $remote"
                fi
            fi
        done
    fi

    local sup_distros=""
    local os_id
    os_id="$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"' 2>/dev/null || echo "arch")"
    sup_distros="$os_id"

    echo
    print_info "Writing package.toml..."
    cat > "$target_dir/package.toml" << TOML
name = "$name"
id = "$id"
version = "$version"
author = "$author"
description = "$description"
license = "$license"
supported_distros = ["$sup_distros"]
reboot_required = false

[packages]
required = [$(echo $pacman_pkgs | sed 's/ */", "/g; s/^/"/; s/$/"/')]
aur = [$(echo $aur_pkgs | sed 's/ */", "/g; s/^/"/; s/$/"/')]

[git]
repositories = [$(echo "$git_repos" | while IFS='|' read -r url path; do [[ -n "$url" ]] && printf '\n  { url = "%s", path = "%s" },' "$url" "$path"; done )

]

[config]
payload_root = "."
install_path = "~"
copy_items = [$(echo "$copy_items" | while IFS='|' read -r src dst; do
    src_clean="$(echo "$src" | xargs)"
    dst_clean="$(echo "$dst" | xargs)"
    [[ -n "$src_clean" && -n "$dst_clean" ]] && printf '\n  "%s|%s",' "$src_clean" "$dst_clean"
done)

]

[hooks]
post_install = "hooks/post-install.sh"
TOML

    print_info "Writing package.conf (legacy)..."
    {
        echo "NAME=\"$name\""
        echo "ID=\"$id\""
        echo "VERSION=\"$version\""
        echo "AUTHOR=\"$author\""
        echo "DESCRIPTION=\"$description\""
        echo "SUPPORTED_DISTROS=\"$sup_distros\""
        echo "PACKAGE_ROOT=\".\""
        echo "REBOOT_REQUIRED=false"
        echo "PACMAN_PACKAGES=\"$pacman_pkgs\""
        echo "AUR_PACKAGES=\"$aur_pkgs\""
        echo "GIT_REPOSITORIES=\"$(echo "$git_repos" | while IFS='|' read -r url path; do [[ -n "$url" ]] && echo "${url}|${path}"; done | tr '\n' ' ')\""
        echo "COPY_ITEMS=\"$(echo "$copy_items" | while IFS='|' read -r src dst; do
            src_clean="$(echo "$src" | xargs)"
            dst_clean="$(echo "$dst" | xargs)"
            [[ -n "$src_clean" && -n "$dst_clean" ]] && echo "${src_clean}|${dst_clean}"
        done | tr '\n' ' ')\""
    } > "$target_dir/package.conf"

    print_info "Writing hcc.manifest..."
    cat > "$target_dir/hcc.manifest" << MANIFEST
HCC_MANIFEST_VERSION=1
ID=$id
NAME="$name"
VERSION=$version
TYPE=desktop-profile
AUTHOR="$author"
MANIFEST

    print_info "Writing hooks/post-install.sh..."
    cat > "$target_dir/hooks/post-install.sh" << 'HOOK'
#!/usr/bin/env bash
# Post-install hook for HCC
# Runs after all packages, configs, and git repos are deployed.

echo "HCC post-install: $NAME"
HOOK
    chmod +x "$target_dir/hooks/post-install.sh"

    if [[ "$copy_payload" == y* || "$copy_payload" == Y* ]]; then
        print_info "Copying config files to payload/..."
        local cfg_dir_name
        for cfg_dir_name in $seen_dirs; do
            local src="$HOME/.config/$cfg_dir_name"
            local dst="$target_dir/payload/.config/$cfg_dir_name"
            if [[ -d "$src" ]]; then
                mkdir -p "$(dirname "$dst")"
                cp -a "$src" "$dst"
                print_success "  Copied: .config/$cfg_dir_name"
            fi
        done
        if [[ -d "$HOME/.config/hypr" && ! " $seen_dirs " =~ " hypr " ]]; then
            mkdir -p "$target_dir/payload/.config/hypr"
            cp -a "$HOME/.config/hypr" "$target_dir/payload/.config/hypr"
            print_success "  Copied: .config/hypr"
        fi
    fi

    echo
    print_success "Profile created: $target_dir"
    echo
    print_info "Files:"
    ls -la "$target_dir"/*.toml "$target_dir"/*.conf "$target_dir"/*.manifest "$target_dir/hooks/" 2>/dev/null
    echo
    print_info "Next steps:"
    echo "  1. Edit $target_dir/package.toml to refine packages and configs"
    echo "  2. Run: hcc desktop install $target_dir"
    echo "  3. Share your profile on GitHub!"
    echo
}
