#!/usr/bin/env bash

check_command() {

    has_command "$1"

}

check_package() {

    has_package "$1"

}

check_service() {

    has_service "$1"

}