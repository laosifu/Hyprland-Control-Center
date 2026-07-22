#!/usr/bin/env bash

run_inspect() {

    local source="${1:-}"

    [[ -n "$source" ]] || {
        print_error "Repository path or URL required"
        return 1
    }

    repository_inspect "$source"

}
