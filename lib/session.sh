#!/usr/bin/env bash

HCC_SESSION_BASE="${XDG_CONFIG_HOME:-$HOME/.config}/hcc/sessions"
HCC_SESSION_ACTIVE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hcc/session-active"

session_base() {
    echo "$HCC_SESSION_BASE"
}

session_dir() {
    local id="$1"
    echo "$(session_base)/$id"
}

session_root() {
    local id="$1"
    echo "$(session_dir "$id")/root"
}

session_config_file() {
    local id="$1"
    echo "$(session_dir "$id")/session.conf"
}

session_manifest_file() {
    local id="$1"
    echo "$(session_dir "$id")/manifest"
}

session_active_file() {
    echo "$HCC_SESSION_ACTIVE_FILE"
}

session_active() {
    local file
    file="$(session_active_file)"
    [[ -f "$file" ]] || return 1
    head -n 1 "$file"
}

session_set_active() {
    local id="$1"
    session_exists "$id" || return 1
    mkdir -p "$(dirname "$(session_active_file)")" || return 1
    printf '%s\n' "$id" > "$(session_active_file)"
}

session_exists() {
    local id="$1"
    [[ -f "$(session_config_file "$id")" ]]
}

session_list() {
    local base
    base="$(session_base)"
    [[ -d "$base" ]] || return 0
    local dir
    for dir in "$base"/*/
    do
        [[ -d "$dir" ]] || continue
        local id
        id="$(basename "$dir")"
        session_exists "$id" && echo "$id"
    done
}

session_register() {
    local id="$1"
    local name="$2"
    local version="$3"
    local source="${4:-local}"

    local dir
    dir="$(session_dir "$id")"
    mkdir -p "$dir" || return 1

    printf 'SESSION_ID=%q\nSESSION_NAME=%q\nSESSION_VERSION=%q\nSESSION_SOURCE=%q\nSESSION_INSTALLED_AT=%q\n' \
        "$id" "$name" "$version" "$source" "$(date -Iseconds)" \
        > "$(session_config_file "$id")"
}

session_load() {
    local id="$1"
    local file
    file="$(session_config_file "$id")"
    [[ -f "$file" ]] || return 1

    unset SESSION_ID SESSION_NAME SESSION_VERSION SESSION_SOURCE SESSION_INSTALLED_AT
    source "$file"
}

session_manifest_add() {
    local id="$1"
    local path="$2"
    local file
    file="$(session_manifest_file "$id")"
    echo "$path" >> "$file"
}

session_manifest_list() {
    local id="$1"
    local file
    file="$(session_manifest_file "$id")"
    [[ -f "$file" ]] || return 0
    sort -u "$file"
}

#
# Symlink-based session isolation
#

session_isolate() {
    local id="$1"

    session_exists "$id" || return 1

    local plan_file
    plan_file="$(profile_registry_directory "$id")/ownership.plan"
    [[ -f "$plan_file" ]] || {
        print_warning "No ownership plan found for profile: $id"
        return 0
    }

    local session_root_dir
    session_root_dir="$(session_root "$id")"
    rm -rf "$session_root_dir"
    mkdir -p "$session_root_dir"

    rm -f "$(session_manifest_file "$id")"

    local count=0
    local ptype parg1 parg2

    while IFS='|' read -r ptype parg1 parg2
    do
        [[ -z "$ptype" ]] && continue

        case "$ptype" in
            COPY_DIRECTORY)
                local src_dir="$parg1"
                local dest
                dest="${parg2/#\~/$HOME}"
                local rel
                rel="${dest/#$HOME\//}"

                if [[ ! -d "$dest" ]]; then
                    continue
                fi

                if [[ "$dest" == "$HOME" ]]; then
                    local entry
                    for entry in "$src_dir"/*
                    do
                        [[ -e "$entry" ]] || continue
                        local name
                        name="$(basename "$entry")"
                        local dest_entry="$HOME/$name"
                        [[ -e "$dest_entry" ]] || continue
                        local session_path="$session_root_dir/$name"
                        mv "$dest_entry" "$session_path"
                        ln -sfn "$session_path" "$dest_entry"
                        session_manifest_add "$id" "$name"
                        ((count++))
                    done
                else
                    local session_path="$session_root_dir/$rel"
                    mkdir -p "$(dirname "$session_path")"
                    mv "$dest" "$session_path"
                    ln -sfn "$session_path" "$dest"
                    session_manifest_add "$id" "$rel"
                    ((count++))
                fi
                ;;
            CLONE_REPOSITORY)
                local dest
                dest="${parg2/#\~/$HOME}"
                local rel
                rel="${dest/#$HOME\//}"
                local session_path="$session_root_dir/$rel"

                if [[ -d "$dest" ]]; then
                    mkdir -p "$(dirname "$session_path")"
                    mv "$dest" "$session_path"
                    ln -sfn "$session_path" "$dest"
                    session_manifest_add "$id" "$rel"
                    ((count++))
                    print_info "Isolated repo: $dest"
                fi
                ;;
        esac
    done < "$plan_file"

    session_set_active "$id"
    print_success "Session isolated: $id ($count items)"
}

session_deploy() {
    local id="$1"
    local rel_path
    local session_root_dir
    local target

    session_exists "$id" || return 1

    session_root_dir="$(session_root "$id")"
    [[ -d "$session_root_dir" ]] || {
        print_error "Session root not found: $id"
        return 1
    }

    while read -r rel_path
    do
        [[ -z "$rel_path" ]] && continue

        target="$HOME/$rel_path"
        local target_dir
        target_dir="$(dirname "$target")"
        local session_path="$session_root_dir/$rel_path"

        [[ -d "$session_path" ]] || {
            print_warning "Session path not found: $session_path"
            continue
        }

        mkdir -p "$target_dir"

        if [[ -e "$target" && ! -L "$target" ]]; then
            print_warning "Backing up existing: $target"
            mv "$target" "$target.hcc-bak-$(date +%s)"
        fi

        ln -sfn "$session_path" "$target"
        print_info "Linked: $target → $session_path"
    done < <(session_manifest_list "$id")

    session_set_active "$id"
    print_success "Session deployed: $id"
}

session_undeploy() {
    local active
    active="$(session_active)" 2>/dev/null || return 0

    local rel_path
    local target

    while read -r rel_path
    do
        [[ -z "$rel_path" ]] && continue
        target="$HOME/$rel_path"

        if [[ -L "$target" ]]; then
            rm "$target"
            print_info "Unlinked: $target"
        fi
    done < <(session_manifest_list "$active")
}

session_undeploy_by_id() {
    local id="$1"
    session_exists "$id" || return 0

    local rel_path
    local target

    while read -r rel_path
    do
        [[ -z "$rel_path" ]] && continue
        target="$HOME/$rel_path"

        if [[ -L "$target" ]]; then
            rm "$target"
            print_info "Unlinked: $target"
        fi
    done < <(session_manifest_list "$id")
}

session_switch() {
    local target_id="$1"
    local current_id

    session_exists "$target_id" || {
        print_error "Session not found: $target_id"
        return 1
    }

    current_id="$(session_active)" 2>/dev/null || true

    if [[ -n "$current_id" && "$current_id" != "$target_id" ]]; then
        print_info "Undeploying session: $current_id"
        session_undeploy
    fi

    print_info "Deploying session: $target_id"
    session_deploy "$target_id"

    echo
    print_success "Session switched to: $target_id"
    print_info "Log out and log in to start Hyprland with the new session."
    print_info "(Or run 'hyprctl reload')"
}

session_remove() {
    local id="$1"
    local active

    session_remove_login_entry "$id"

    session_undeploy_by_id "$id"

    local dir
    dir="$(session_dir "$id")"
    [[ -d "$dir" ]] && rm -rf "$dir"

    local active
    active="$(session_active)" 2>/dev/null || true
    if [[ "$active" == "$id" ]]; then
        rm -f "$(session_active_file)"
    fi
}

session_build_manifest_from_plan() {
    local id="$1"
    local found=false
    local action
    local dest rel

    rm -f "$(session_manifest_file "$id")"

    for action in "${PLAN_ACTIONS[@]}"
    do
        plan_record_read "$action"

        case "$PLAN_RECORD_TYPE" in
            COPY_DIRECTORY|CLONE_REPOSITORY)
                dest="${PLAN_RECORD_ARG2/#\~/$HOME}"
                rel="${dest/#$HOME\//}"
                [[ "$rel" == "$dest" ]] && continue
                session_manifest_add "$id" "$rel"
                found=true
                ;;
        esac
    done

    [[ "$found" == true ]]
}

session_setup_login_entry() {
    local id="$1"
    session_load "$id" || return 1

    local name="${SESSION_NAME:-$id}"
    local hypr_config
    hypr_config="$(session_get_hypr_config "$id")" || return 1

    local desktop_file="/usr/share/wayland-sessions/hcc-$id.desktop"

    if [[ ! -f "$desktop_file" ]]; then
        if [[ -w "/usr/share/wayland-sessions" ]]; then
            cat > "$desktop_file" << EOF
[Desktop Entry]
Name=HCC - $name
Comment=Hyprland with $name session configuration
Exec=/usr/lib/hcc/session-launcher $id
Type=Application
DesktopNames=Hyprland
EOF
            print_success "Login entry created: $desktop_file"
        else
            print_info "Login entry not created (need root). Run: sudo hcc session setup-login"
        fi
    fi
}

session_setup_login_entries() {
    local id
    local name
    local hypr_config
    local desktop_file

    for id in $(session_list)
    do
        session_load "$id" || continue
        name="${SESSION_NAME:-$id}"
        hypr_config="$(session_get_hypr_config "$id")" || continue

        desktop_file="/usr/share/wayland-sessions/hcc-$id.desktop"

        if [[ ! -f "$desktop_file" ]]; then
            if [[ -w "/usr/share/wayland-sessions" ]]; then
                print_info "Creating session entry: $desktop_file"
                cat > "$desktop_file" << EOF
[Desktop Entry]
Name=HCC - $name
Comment=Hyprland with $name session configuration
Exec=/usr/lib/hcc/session-launcher $id
Type=Application
DesktopNames=Hyprland
EOF
            else
                print_info "Session entry would be created at: $desktop_file"
                print_info "Run with sudo to create login entries."
            fi
        fi
    done
}

session_remove_login_entry() {
    local id="$1"
    local desktop_file="/usr/share/wayland-sessions/hcc-$id.desktop"

    if [[ -f "$desktop_file" ]]; then
        rm -f "$desktop_file" 2>/dev/null && \
            print_info "Removed session entry: $desktop_file" || \
            print_info "Could not remove $desktop_file (run as root)"
    fi
}

session_get_hypr_config() {
    local id="$1"
    local root_dir
    root_dir="$(session_root "$id")"

    local path
    for path in \
        "$root_dir/.config/hypr/hyprland.lua" \
        "$root_dir/.config/hypr/hyprland.conf" \
        "$root_dir/hypr/hyprland.lua" \
        "$root_dir/hypr/hyprland.conf"
    do
        [[ -f "$path" ]] && { echo "$path"; return 0; }
    done

    return 1
}

session_get_hypr_dir() {
    local id="$1"
    local root_dir
    root_dir="$(session_root "$id")"

    local path
    for path in \
        "$root_dir/.config/hypr" \
        "$root_dir/hypr"
    do
        [[ -d "$path" ]] && { echo "$path"; return 0; }
    done

    return 1
}
