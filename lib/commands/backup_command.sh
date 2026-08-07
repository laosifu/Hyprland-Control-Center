#!/usr/bin/env bash

backup_dispatch() {

    local sub="${1:-list}"

    case "$sub" in
        create)
            shift
            log_info "Running backup"
            run_backup "$@"
            ;;
        list|"")
            log_info "Listing backups"
            run_backup_list
            ;;
        restore)
            shift
            log_info "Running restore"
            run_restore "$@"
            ;;
        *)
            print_error "Usage: hcc backup <create|list|restore> [name]"
            return 1
            ;;
    esac

}
