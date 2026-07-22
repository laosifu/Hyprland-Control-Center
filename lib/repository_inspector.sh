#!/usr/bin/env bash

repository_manifest_file() {

    echo "$1/hcc.manifest"

}

repository_manifest_value() {

    local file="$1"
    local key="$2"

    sed -n "s/^${key}=//p" "$file" | head -n 1

}

repository_manifest_load() {

    local repository="$1"
    local file

    file="$(repository_manifest_file "$repository")"
    [[ -f "$file" ]] || return 1

    REPOSITORY_MANIFEST_VERSION="$(repository_manifest_value "$file" HCC_MANIFEST_VERSION)"
    REPOSITORY_ID="$(repository_manifest_value "$file" ID)"
    REPOSITORY_NAME="$(repository_manifest_value "$file" NAME)"
    REPOSITORY_VERSION="$(repository_manifest_value "$file" VERSION)"
    REPOSITORY_TYPE="$(repository_manifest_value "$file" TYPE)"
    REPOSITORY_AUTHOR="$(repository_manifest_value "$file" AUTHOR)"
    REPOSITORY_DESCRIPTION="$(repository_manifest_value "$file" DESCRIPTION)"

}

repository_manifest_validate() {

    [[ "$REPOSITORY_MANIFEST_VERSION" == 1 ]] || return 1
    profile_registry_validate_id "$REPOSITORY_ID" || return 1
    [[ -n "$REPOSITORY_NAME" && -n "$REPOSITORY_VERSION" && -n "$REPOSITORY_AUTHOR" ]] || return 1
    [[ "$REPOSITORY_TYPE" == desktop-profile ]] || return 1

}

repository_inspect() {

    local source="$1"
    local repository="$source"
    local temporary=false

    if [[ ! -d "$repository" ]]; then
        case "$source" in
            https://*|http://*|git@*)
                execution_is_dry_run && {
                    print_info "[DRY-RUN] Would clone $source for inspection."
                    return 0
                }
                repository="$(mktemp -d)"
                git clone --depth 1 "$source" "$repository" || {
                    rmdir "$repository" 2>/dev/null || true
                    return 1
                }
                temporary=true
                ;;
            *)
                print_error "Repository path or URL not found: $source"
                return 1
                ;;
        esac
    fi

    if ! repository_manifest_load "$repository" || ! repository_manifest_validate; then
        print_warning "No supported HCC manifest found. Inspection only; nothing will be installed."
        [[ "$temporary" == true ]] && rm -rf "$repository"
        return 1
    fi

    print_header "Repository Inspection"
    ui_field "Name" "$REPOSITORY_NAME"
    ui_field "ID" "$REPOSITORY_ID"
    ui_field "Version" "$REPOSITORY_VERSION"
    ui_field "Author" "$REPOSITORY_AUTHOR"
    ui_field "Type" "$REPOSITORY_TYPE"
    ui_field "Status" "Manifest valid — preview/import is safe"

    [[ -n "$REPOSITORY_DESCRIPTION" ]] && ui_field "Description" "$REPOSITORY_DESCRIPTION"

    [[ "$temporary" == true ]] && rm -rf "$repository"

    return 0

}
