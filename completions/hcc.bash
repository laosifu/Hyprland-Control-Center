_hcc_completions() {
    local cur prev words cword
    _init_completion || return

    local commands="doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version"
    local desktop_actions="list search install uninstall update init submit"
    local profile_actions="list status switch"
    local session_actions="setup-login"
    local theme_actions="list install uninstall"
    local plugin_actions="install uninstall"
    local ai_actions="setup status remove-key help"

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return
    fi

    case "${words[1]}" in
        desktop)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$desktop_actions" -- "$cur"))
            elif [[ $cword -eq 3 && "${words[2]}" == "install" ]]; then
                COMPREPLY=($(compgen -W "$(hcc desktop list 2>/dev/null | grep '^  ' | awk '{print $1}')" -- "$cur"))
            fi
            ;;
        profile)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$profile_actions" -- "$cur"))
            elif [[ $cword -eq 3 && "${words[2]}" == "switch" ]]; then
                COMPREPLY=($(compgen -W "$(hcc profile list 2>/dev/null | grep '^-' | awk '{print $2}')" -- "$cur"))
            fi
            ;;
        session)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$session_actions" -- "$cur"))
            fi
            ;;
        theme)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$theme_actions" -- "$cur"))
            elif [[ $cword -eq 3 && "${words[2]}" == "install" ]]; then
                COMPREPLY=($(compgen -W "$(hcc theme list 2>/dev/null | grep '^-' | awk '{print $2}')" -- "$cur"))
            fi
            ;;
        plugin)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$plugin_actions" -- "$cur"))
            elif [[ $cword -eq 3 && "${words[2]}" == "install" ]]; then
                COMPREPLY=($(compgen -W "$(hcc plugins 2>/dev/null | grep '^-' | awk '{print $2}')" -- "$cur"))
            fi
            ;;
        ai)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$ai_actions" -- "$cur"))
            fi
            ;;
        inspect|get)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$(hcc desktop list 2>/dev/null | grep '^  ' | awk '{print $1}')" -- "$cur"))
            fi
            ;;
        restore)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=($(compgen -W "$(hcc restore 2>/dev/null | grep '^  ' | awk '{print $1}')" -- "$cur"))
            fi
            ;;
    esac
}

complete -F _hcc_completions hcc
