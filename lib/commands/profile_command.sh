#!/usr/bin/env bash

profile_dispatch() {

    case "${1:-list}" in
        list)
            run_profiles
            ;;
        status)
            run_profile_status
            ;;
        *)
            print_error "Usage: hcc profile <list|status>"
            return 1
            ;;
    esac

}
