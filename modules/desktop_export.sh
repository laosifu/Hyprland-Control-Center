run_desktop_export() {
    local id="$1"
    local export_dir="${2:-.}"

    if [[ -z "$id" ]]; then
        print_error "Usage: hcc desktop export <id> [output-dir]"
        print_info "Xuat profile da cai thanh package.toml de chia se voi cong dong."
        return 1
    fi

    if ! profile_registry_exists "$id"; then
        print_error "Profile not found: $id"
        print_info "Use: hcc profile list"
        return 1
    fi

    profile_registry_load "$id" || return 1

    local out_dir="$export_dir/$id"
    mkdir -p "$out_dir"

    print_info "Xuat profile '$id' ra $out_dir..."

    local required_packages=""
    local aur_packages=""
    local git_repos=""
    local copy_items=""
    local plan_file

    plan_file="$(profile_registry_directory "$id")/ownership.plan"

    if [[ -f "$plan_file" ]]; then
        while IFS='|' read -r ptype parg1 parg2
        do
            [[ -z "$ptype" ]] && continue
            case "$ptype" in
                COPY_DIRECTORY)
                    copy_items="$copy_items $parg1"
                    ;;
                CLONE_REPOSITORY)
                    local repo_url=""
                    if [[ -d "${parg2/#\~/$HOME}" ]]; then
                        repo_url=$(cd "${parg2/#\~/$HOME}" && git remote get-url origin 2>/dev/null) || true
                    fi
                    if [[ -n "$repo_url" ]]; then
                        git_repos="$git_repos $repo_url|$parg2"
                    fi
                    ;;
                INSTALL_PACKAGE)
                    required_packages="$required_packages $parg1"
                    ;;
                INSTALL_AUR)
                    aur_packages="$aur_packages $parg1"
                    ;;
            esac
        done < "$plan_file"
    fi

    cat > "$out_dir/package.toml" << TOML_EOF
name = "${PROFILE_NAME:-$id}"
id = "$id"
version = "${PROFILE_VERSION:-1.0}"
author = "${PROFILE_AUTHOR:-unknown}"

[packages]
required = [$(echo $required_packages | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | sed 's/", ""/", "/g')]
aur = [$(echo $aur_packages | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | sed 's/", ""/", "/g')]

[git]
repositories = [
$(echo "$git_repos" | tr ' ' '\n' | while IFS='|' read -r url path; do
    [[ -z "$url" ]] && continue
    echo "    { url = \"$url\", path = \"${path/#$HOME/~}\" },"
done)
]

[config]
payload_root = "payload"
install_path = "~"

[hooks]
post_install = "hooks/post-install.sh"
TOML_EOF

    # Legacy format
    cat > "$out_dir/package.conf" << CONF_EOF
PACMAN_PACKAGES="$(echo $required_packages | xargs)"
AUR_PACKAGES="$(echo $aur_packages | xargs)"
GIT_REPOSITORIES="$(echo $git_repos | tr ' ' '\n' | while IFS='|' read -r url path; do
    [[ -z "$url" ]] && continue
    echo "${url}|${path/#$HOME/~}"
done | tr '\n' ' ' | xargs)"
COPY_ITEMS="$(echo $copy_items | xargs)"
CONF_EOF

    # manifest
    cat > "$out_dir/hcc.manifest" << MAN_EOF
HCC_MANIFEST_VERSION=1
HCC_TYPE=desktop-profile
HCC_ID=$id
HCC_NAME=${PROFILE_NAME:-$id}
HCC_VERSION=${PROFILE_VERSION:-1.0}
HCC_AUTHOR=${PROFILE_AUTHOR:-unknown}
HCC_DESCRIPTION="Exported from $id"
MAN_EOF

    # Create hooks directory
    mkdir -p "$out_dir/hooks"
    cat > "$out_dir/hooks/post-install.sh" << 'HOOK_EOF'
#!/usr/bin/env bash
# Post-install hook for this desktop profile
# Add custom commands here (e.g., systemctl enable services)
HOOK_EOF
    chmod +x "$out_dir/hooks/post-install.sh"

    print_success "Da xuat profile '$id' ra: $out_dir"
    echo
    echo "  Cac file da tao:"
    echo "    • package.toml      — Dinh dang TOML (khuyen dung)"
    echo "    • package.conf      — Dinh dang cu (tuong thich)"
    echo "    • hcc.manifest      — Thong tin profile"
    echo "    • hooks/post-install.sh — Hook tuy chinh"
    echo
    print_info "De chia se:"
    echo "  1. Tao GitHub repo tu $out_dir"
    echo "  2. Chay: hcc desktop submit $id"
    echo "  3. Hoac chia se link: hcc desktop install https://github.com/<ban>/<repo>"
}
