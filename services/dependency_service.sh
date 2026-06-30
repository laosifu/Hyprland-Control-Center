#!/usr/bin/env bash

dependency_install_pacman() {

    sudo pacman -S --needed "$@"

}

dependency_install_aur() {

    yay -S --needed "$@"

}