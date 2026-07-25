#!/usr/bin/env bash

desktop_pipeline_run() {

    desktop_pipeline_prepare \
    || return 1

    desktop_pipeline_execute \
    || return 1

    desktop_pipeline_finalize

}
desktop_pipeline_prepare() {

    desktop_prepare

}

desktop_pipeline_execute() {

    deployment_service_execute_plan

}

desktop_pipeline_finalize() {

    local id="${ID:-}"

    if [[ -n "$id" && -w "/usr/share/wayland-sessions" ]]; then

        local desktop_file="/usr/share/wayland-sessions/hcc.desktop"
        if [[ ! -f "$desktop_file" ]]; then
            cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Name=HCC
Comment=Hyprland Control Center
Exec=/usr/lib/hcc/session-launcher
Type=Application
DesktopNames=Hyprland
EOF
        fi

    fi

    desktop_finalize_message

    hook_service_run "$(desktop_package_hook "$ID" post-install)"

}
