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
        apt:brightnessctl)   echo "brightnessctl" ;;
        apt:matugen)         echo "matugen" ;;
        apt:starship)        echo "starship" ;;
        apt:fish)            echo "fish" ;;
        apt:bc)              echo "bc" ;;
        apt:nautilus)        echo "nautilus" ;;

        dnf:hyprland)        echo "hyprland" ;;
        dnf:hyprpaper)       echo "hyprpaper" ;;
        dnf:kitty)           echo "kitty" ;;
        dnf:waybar)          echo "waybar" ;;
        dnf:wofi)            echo "wofi" ;;
        dnf:dunst)           echo "dunst" ;;
        dnf:rofi)            echo "rofi" ;;
        dnf:swww)            echo "swww" ;;
        dnf:swaync)          echo "swaync" ;;
        dnf:thunar)          echo "thunar" ;;
        dnf:btop)            echo "btop" ;;
        dnf:cava)            echo "cava" ;;
        dnf:mpv)             echo "mpv" ;;
        dnf:firefox)         echo "firefox" ;;
        dnf:pipewire)        echo "pipewire" ;;
        dnf:wireplumber)     echo "wireplumber" ;;
        dnf:grim)            echo "grim" ;;
        dnf:slurp)           echo "slurp" ;;
        dnf:swappy)          echo "swappy" ;;
        dnf:wl-clipboard)    echo "wl-clipboard" ;;
        dnf:jq)              echo "jq" ;;
        dnf:curl)            echo "curl" ;;
        dnf:git)             echo "git" ;;
        dnf:unzip)           echo "unzip" ;;
        dnf:ripgrep)         echo "ripgrep" ;;
        dnf:fd)              echo "fd-find" ;;
        dnf:fzf)             echo "fzf" ;;
        dnf:tmux)            echo "tmux" ;;
        dnf:neovim)          echo "neovim" ;;
        dnf:python)          echo "python3" ;;
        dnf:hyprlock)        echo "hyprlock" ;;
        dnf:hypridle)        echo "hypridle" ;;
        dnf:hyprpicker)      echo "hyprpicker" ;;
        dnf:hyprsunset)      echo "hyprsunset" ;;
        dnf:brightnessctl)   echo "brightnessctl" ;;
        dnf:nautilus)        echo "nautilus" ;;
        dnf:starship)        echo "starship" ;;
        dnf:fish)            echo "fish" ;;
        dnf:bc)              echo "bc" ;;

        zypper:fd)           echo "fd" ;;
        zypper:ripgrep)      echo "ripgrep" ;;
        zypper:kitty)        echo "kitty" ;;
        zypper:waybar)       echo "waybar" ;;
        zypper:fzf)          echo "fzf" ;;
        zypper:neovim)       echo "neovim" ;;
        zypper:python)       echo "python3" ;;

        xbps:fd)             echo "fd" ;;
        xbps:ripgrep)        echo "ripgrep" ;;
        xbps:kitty)          echo "kitty" ;;
        xbps:waybar)         echo "waybar" ;;
        xbps:neovim)         echo "neovim" ;;
        xbps:python)         echo "python3" ;;

        apk:fd)              echo "fd" ;;
        apk:ripgrep)         echo "ripgrep" ;;
        apk:kitty)           echo "kitty" ;;
        apk:waybar)          echo "waybar" ;;
        apk:neovim)          echo "neovim" ;;
        apk:python)          echo "python3" ;;

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
