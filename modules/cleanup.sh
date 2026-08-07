#!/usr/bin/env bash

run_cleanup() {

    print_header "Cleanup Engine"

    cleanup_scan

}

cleanup_scan() {

    scan_and_print \
        "User cache" \
        "$HOME/.cache"

    scan_and_print \
        "Pacman cache" \
        "/var/cache/pacman/pkg"

    scan_and_print \
        "Yay cache" \
        "$HOME/.cache/yay"

    scan_and_print \
        "Cargo cache" \
        "$HOME/.cargo/registry"

    scan_and_print \
        "Pip cache" \
        "$HOME/.cache/pip"

    scan_and_print \
        "NPM cache" \
        "$HOME/.npm"

}