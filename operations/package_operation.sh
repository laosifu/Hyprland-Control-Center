#!/usr/bin/env bash

package_operation_install() {
    pm_install "$1"
}

package_operation_remove() {
    pm_remove "$@"
}
