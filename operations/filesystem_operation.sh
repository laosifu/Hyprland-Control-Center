#!/usr/bin/env bash

filesystem_operation_create_directory() {

    operation_run \
        mkdir \
        -p \
        "$1"

}

filesystem_operation_remove() {

    operation_run \
        rm \
        -rf \
        "$1"

}

filesystem_operation_copy_directory() {

    local source="$1"
    local destination="$2"
    local target_dir="$destination/$(basename "$source")"

    if [[ -d "$target_dir" ]]; then
        local item
        for item in "$source"/* "$source"/.*; do
            [[ -e "$item" ]] || continue
            local basename_item
            basename_item="$(basename "$item")"
            [[ "$basename_item" == "." || "$basename_item" == ".." ]] && continue
            local dest_path="$target_dir/$basename_item"
            if [[ -L "$dest_path" ]]; then
                rm -f "$dest_path"
            fi
        done
    fi

    operation_run \
        cp \
        -a \
        "$source" \
        "$destination/"

}