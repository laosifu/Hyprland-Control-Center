#!/usr/bin/env bash
scan_directory() {

    local dir="$1"

    [[ -d "$dir" ]] || return 1

    du -sh "$dir" 2>/dev/null | cut -f1

}
scan_and_print() {

    local label="$1"
    local dir="$2"

    local size

    if size=$(scan_directory "$dir"); then

        print_info "$label : $size"

    else

        print_warning "$label : Not found"

    fi

}
show_help() {

cat <<EOF

Hyprland Control Center

Cai dat desktop Hyprland de dang.

SU DUNG:

    hcc <lenh> [doi so]

LENH:

    hcc doctor              Kiem tra he thong
    hcc desktop list        Xem desktop packages co san
    hcc desktop search <tu khoa> Tim desktop tu community registry
    hcc desktop install <ten|url|dir>  Cai desktop (registry/URL/thu muc)
    hcc desktop update <id>            Cap nhat desktop da cai
    hcc desktop init [dir]             Tao desktop profile moi (wizard)

    hcc profile list        Xem profile da cai
    hcc profile status      Xem profile dang dung
    hcc profile switch <id> Chuyen doi profile (chuyen active)

    hcc session list        Xem danh sach session
    hcc session switch      Menu tuong tac chon session
    hcc session setup-login Tao login entries cho Display Manager

    hcc backup              Backup config hien tai
    hcc restore [id]        Khoi phuc tu backup

    hcc theme list          Xem themes
    hcc theme install <ten> Cai theme
    hcc theme uninstall <ten> Go theme

    hcc plugins             Xem plugins
    hcc plugin install <ten>  Cai plugin
    hcc plugin uninstall <ten> Go plugin

    hcc inventory           Kiem tra thanh phan he thong
    hcc cleanup             Xem dung luong cache
    hcc inspect <path>      Xem thong tin repository

    hcc ai setup            Cai dat API key cho AI (Gemini)
    hcc ai remove-key       Xoa API key
    hcc ai status           Kiem tra trang thai AI

    hcc --version           Phien ban
    hcc help                Tro giup nay

VI DU:

    hcc desktop list
    hcc desktop install mailong2401
    hcc desktop install https://github.com/end-4/dots-hyprland
    hcc profile switch end-4

Xem README.md de biet huong dan chi tiet.

EOF
}
