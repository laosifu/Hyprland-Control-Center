#!/usr/bin/env bash

COLOR_RESET="\033[0m"

COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_MAGENTA="\033[35m"
COLOR_CYAN="\033[36m"

COLOR_BOLD="\033[1m"

print_info() {
    echo -e "${COLOR_CYAN}$*${COLOR_RESET}"
}

print_success() {
    echo -e "${COLOR_GREEN}$*${COLOR_RESET}"
}

print_warn() {
    echo -e "${COLOR_YELLOW}$*${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_RED}$*${COLOR_RESET}"
}

print_header() {

    echo

    echo -e "${COLOR_BOLD}${COLOR_BLUE}========================================${COLOR_RESET}"

    echo -e "${COLOR_BOLD}$*${COLOR_RESET}"

    echo -e "${COLOR_BOLD}${COLOR_BLUE}========================================${COLOR_RESET}"

}
