#!/usr/bin/env bash

pm_map_name() {
    local pkg="$1"

    case "${HCC_PM}:${pkg}" in
        apt:hyprland)        echo "hyprland" ;;
        apt:hyprpaper)       echo "hyprpaper" ;;
        apt:kitty)           echo "kitty" ;;
        apt:waybar)          echo "waybar" ;;
        apt:wofi)            echo "wofi" ;;
        apt:dunst)           echo "dunst" ;;
        apt:rofi)            echo "rofi" ;;
        apt:swww)            echo "swww" ;;
        apt:swaync)          echo "swaync" ;;
        apt:thunar)          echo "thunar" ;;
        apt:btop)            echo "btop" ;;
        apt:cava)            echo "cava" ;;
        apt:mpv)             echo "mpv" ;;
        apt:firefox)         echo "firefox" ;;
        apt:pulseaudio)      echo "pulseaudio" ;;
        apt:pavucontrol)     echo "pavucontrol" ;;
        apt:pipewire)        echo "pipewire" ;;
        apt:wireplumber)     echo "wireplumber" ;;
        apt:grim)            echo "grim" ;;
        apt:slurp)           echo "slurp" ;;
        apt:swappy)          echo "swappy" ;;
        apt:wl-clipboard)    echo "wl-clipboard" ;;
        apt:jq)              echo "jq" ;;
        apt:curl)            echo "curl" ;;
        apt:git)             echo "git" ;;
        apt:unzip)           echo "unzip" ;;
        apt:ripgrep)         echo "ripgrep" ;;
        apt:fd)              echo "fd-find" ;;
        apt:fzf)             echo "fzf" ;;
        apt:tmux)            echo "tmux" ;;
        apt:neovim)          echo "neovim" ;;
        apt:python)          echo "python3" ;;
        apt:hyprlock)        echo "hyprlock" ;;
        apt:hypridle)        echo "hypridle" ;;
        apt:hyprpicker)      echo "hyprpicker" ;;
        apt:hyprsunset)      echo "hyprsunset" ;;
        dnf:swww)            echo "swww" ;;
        dnf:swaync)          echo "swaync" ;;
        dnf:wl-clipboard)    echo "wl-clipboard" ;;
        dnf:fd)              echo "fd-find" ;;
        dnf:python)          echo "python3" ;;
        flatpak:kitty)       echo "org.keepassxc.KeePassXC" ;;
        flatpak:firefox)     echo "org.mozilla.firefox" ;;
        flatpak:mpv)         echo "io.mpv.Mpv" ;;
        flatpak:thunar)      echo "org.xfce.thunar" ;;
        flatpak:btop)        echo "com.topgrade.Btop" ;;
        flatpak:obsidian)    echo "md.obsidian.Obsidian" ;;
        flatpak:spotify)     echo "com.spotify.Client" ;;
        flatpak:discord)     echo "com.discordapp.Discord" ;;
        flatpak:slack)       echo "com.slack.Slack" ;;
        flatpak:gimp)        echo "org.gimp.GIMP" ;;
        flatpak:inkscape)    echo "org.inkscape.Inkscape" ;;
        flatpak:vlc)         echo "org.videolan.VLC" ;;
        flatpak:libreoffice) echo "org.libreoffice.LibreOffice" ;;
        *)
            echo "$pkg"
            ;;
    esac
}
