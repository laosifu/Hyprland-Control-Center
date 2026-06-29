#!/usr/bin/env bash

create_backup() {

    local backup_root

    backup_root="$(get_backup_dir)"

    local timestamp

    timestamp=$(date +"%Y%m%d-%H%M%S")

    local target

    target="$backup_root/$timestamp"

    mkdir -p "$target"
    
    write_manifest "$target"

    print_info "Backup directory"

    print_info "$target"

    copy_if_exists "$HOME/.config/hypr" "$target"

    copy_if_exists "$HOME/.config/waybar" "$target"

    copy_if_exists "$HOME/.config/rofi" "$target"

    copy_if_exists "$HOME/.config/kitty" "$target"

    copy_if_exists "$HOME/.config/fish" "$target"

    print_success "Backup completed"

}

run_backup() {

    print_header "Backup Engine"

    create_backup

}