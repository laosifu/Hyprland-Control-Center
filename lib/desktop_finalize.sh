#!/usr/bin/env bash

desktop_finalize() {

    desktop_finalize_reload

    desktop_finalize_message

}

desktop_finalize_reload() {

    return 0

}

desktop_finalize_message() {

    print_success "Desktop installation completed."

}