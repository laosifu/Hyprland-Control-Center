#!/usr/bin/env bash

aur_query_is_installed() {

    pacman -Qi "$1" >/dev/null 2>&1

}
