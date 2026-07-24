#!/usr/bin/env bash

ai_dispatch() {

    case "${1:-help}" in

        setup)
            desktop_ai_setup
            ;;

        remove-key)
            desktop_ai_remove_key
            ;;

        status)
            if desktop_ai_load_key; then
                print_success "AI API key is configured."
                print_info "File: $HCC_AI_CONFIG_FILE"
            else
                print_warning "AI API key is not configured."
                print_info "Run: hcc ai setup"
            fi
            ;;

        help|--help)
            ai_show_help
            ;;

        *)
            print_error "Usage: hcc ai <setup|remove-key|status>"
            return 1
            ;;

    esac

}

ai_show_help() {

    print_header "HCC AI Integration"
    echo
    print_info "HCC uses Google Gemini (free) to auto-analyze dotfiles repositories"
    print_info "and generate package.conf when installing from URL."
    echo
    print_info "Commands:"
    echo "  hcc ai setup         Setup/configure AI API key"
    echo "  hcc ai remove-key    Remove stored API key"
    echo "  hcc ai status        Check AI API key status"
    echo
    print_info "Get a free API key: https://aistudio.google.com/apikey"
    echo
    print_info "The AI is invoked automatically when installing from URL:"
    echo "  hcc desktop install https://github.com/user/dotfiles"
    echo
    print_info "If AI is not configured, HCC will fall back to auto-detect."

}
