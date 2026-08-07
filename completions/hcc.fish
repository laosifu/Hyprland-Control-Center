complete -c hcc -f

# Top-level commands
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a doctor -d "System health check"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a inventory -d "Detailed component inventory"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a cleanup -d "Scan cache sizes"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a inspect -d "Inspect a desktop repository"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a desktop -d "Desktop management"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a profile -d "Profile management"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a session -d "Session management"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a backup -d "Backup current config"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a restore -d "Restore from backup"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a theme -d "Theme management"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a plugins -d "List plugins"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a plugin -d "Plugin management"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a ai -d "AI integration"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a get -d "Install desktop (super command)"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -a help -d "Show help"
complete -c hcc -n "not __fish_seen_subcommand_from doctor inventory cleanup inspect desktop profile session backup restore theme plugin plugins ai get help --version" -l version -d "Show version"

# desktop subcommands
complete -c hcc -n "__fish_seen_subcommand_from desktop" -f
complete -c hcc -n "__fish_seen_subcommand_from desktop" -a list -d "List available desktops"
complete -c hcc -n "__fish_seen_subcommand_from desktop" -a search -d "Search community registry"
complete -c hcc -n "__fish_seen_subcommand_from desktop; and not __fish_seen_subcommand_from list search install uninstall update init submit" -a install -d "Preview and install desktop"
complete -c hcc -n "__fish_seen_subcommand_from desktop; and not __fish_seen_subcommand_from list search install uninstall update init submit" -a uninstall -d "Remove desktop with rollback"
complete -c hcc -n "__fish_seen_subcommand_from desktop; and not __fish_seen_subcommand_from list search install uninstall update init submit" -a update -d "Update installed desktop"
complete -c hcc -n "__fish_seen_subcommand_from desktop; and not __fish_seen_subcommand_from list search install uninstall update init submit" -a init -d "Create desktop profile (wizard)"
complete -c hcc -n "__fish_seen_subcommand_from desktop; and not __fish_seen_subcommand_from list search install uninstall update init submit" -a submit -d "Submit to community registry"
complete -c hcc -n "__fish_seen_subcommand_from desktop; and __fish_seen_subcommand_from install" -a "(hcc desktop list 2>/dev/null | string match -r '^  \\S+' | string trim)" -d "Desktop name"

# profile subcommands
complete -c hcc -n "__fish_seen_subcommand_from profile" -f
complete -c hcc -n "__fish_seen_subcommand_from profile" -a list -d "View installed profiles"
complete -c hcc -n "__fish_seen_subcommand_from profile; and not __fish_seen_subcommand_from list status switch" -a status -d "Show active profile"
complete -c hcc -n "__fish_seen_subcommand_from profile; and not __fish_seen_subcommand_from list status switch" -a switch -d "Switch active profile"

# session subcommands
complete -c hcc -n "__fish_seen_subcommand_from session" -f
complete -c hcc -n "__fish_seen_subcommand_from session" -a "setup-login" -d "Create DM login entries"

# theme subcommands
complete -c hcc -n "__fish_seen_subcommand_from theme" -f
complete -c hcc -n "__fish_seen_subcommand_from theme" -a list -d "List themes"
complete -c hcc -n "__fish_seen_subcommand_from theme; and not __fish_seen_subcommand_from list install uninstall" -a install -d "Install a theme"
complete -c hcc -n "__fish_seen_subcommand_from theme; and not __fish_seen_subcommand_from list install uninstall" -a uninstall -d "Uninstall a theme"

# plugin subcommands
complete -c hcc -n "__fish_seen_subcommand_from plugin" -f
complete -c hcc -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from install uninstall" -a install -d "Install a plugin"
complete -c hcc -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from install uninstall" -a uninstall -d "Uninstall a plugin"

# ai subcommands
complete -c hcc -n "__fish_seen_subcommand_from ai" -f
complete -c hcc -n "__fish_seen_subcommand_from ai" -a setup -d "Configure Gemini API key"
complete -c hcc -n "__fish_seen_subcommand_from ai; and not __fish_seen_subcommand_from setup status remove-key help" -a status -d "Check AI configuration"
complete -c hcc -n "__fish_seen_subcommand_from ai; and not __fish_seen_subcommand_from setup status remove-key help" -a remove-key -d "Remove API key"
complete -c hcc -n "__fish_seen_subcommand_from ai; and not __fish_seen_subcommand_from setup status remove-key help" -a help -d "AI help"
