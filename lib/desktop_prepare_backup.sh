#!/usr/bin/env bash

desktop_prepare_backup() {

    backup_service_backup_directory \
        ~/.config \
        ~/.local/share/hcc/backups/config

}