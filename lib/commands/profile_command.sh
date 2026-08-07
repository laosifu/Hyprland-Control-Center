#!/usr/bin/env bash

profile_dispatch() {

    case "${1:-list}" in
        list)
            run_profiles
            ;;
        status)
            run_profile_status
            ;;
        switch)
            shift
            run_profile_switch "$@"
            ;;
        *)
            print_error "Usage: hcc profile <list|status|switch> [id]"
            return 1
            ;;
    esac

}
