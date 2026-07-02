#!/usr/bin/env bash

filesystem_copy_directory() {

    local dry_run=false
    local force=false
    local backup=false
    local verbose=false

    while [[ $# -gt 0 ]]; do

        case "$1" in

            --dry-run)

                dry_run=true
                shift
                ;;

            --force)

                force=true
                shift
                ;;

            --backup)

                backup=true
                shift
                ;;

            --verbose)

                verbose=true
                shift
                ;;

            *)

                break
                ;;

        esac

    done

    local source="$1"

    local destination="$2"

    echo "source=$source"

    echo "destination=$destination"

    echo "dry_run=$dry_run"

    echo "force=$force"

    echo "backup=$backup"

    echo "verbose=$verbose"

}