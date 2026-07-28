dependency_check_installed() {
    local pkg="$1"
    pm_installed "$pkg"
}

dependency_check_command() {
    local cmd="$1"
    command -v "$cmd" &>/dev/null
}

dependency_check_available() {
    local pkg="$1"
    pm_available "$pkg"
}
