#!/usr/bin/env bash

config_read() {
    local file="$1"

    [[ -f "$file" ]] || return 1

    case "$file" in
        *.toml)
            config_parse_toml "$file"
            ;;
        *.conf)
            # shellcheck disable=SC1090
            source "$file"
            ;;
        *)
            # shellcheck disable=SC1090
            source "$file"
            ;;
    esac
}

config_parse_toml() {
    local file="$1"

    if command -v python3 &>/dev/null; then
        config_parse_toml_python "$file"
    else
        config_parse_toml_bash "$file"
    fi
}

config_parse_toml_python() {
    local file="$1"

    while IFS='=' read -r key value; do
        [[ -z "$key" ]] && continue

        local clean_key="${key%.}"
        local var_name
        var_name="$(echo "$clean_key" | tr 'a-z.-' 'A-Z__')"

        if [[ "$key" == *"."LIST ]]; then
            local len_var="${var_name%_LIST}__LEN"
            printf -v "$len_var" '%s' "$value"
            continue
        fi

        printf -v "$var_name" '%s' "$value"
    done < <(
    python3 -c "
import sys
try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        print('HCC: No TOML parser found (install python-tomli)', file=sys.stderr)
        sys.exit(1)

with open('$file', 'rb') as f:
    data = tomllib.load(f)

def emit(prefix, val):
    if isinstance(val, dict):
        for k, v in val.items():
            emit(f'{prefix}{k}.', v)
    elif isinstance(val, list):
        print(f'{prefix}LIST={len(val)}')
        for i, v in enumerate(val):
            emit(f'{prefix}{i}.', v)
    elif isinstance(val, bool):
        print(f'{prefix}={str(val).lower()}')
    else:
        print(f'{prefix}={val}')

for k, v in data.items():
    emit(f'{k}.', v)
" 2>/dev/null
    )
}

config_toml_to_legacy() {

    local i pkg

    PACKAGES=""
    for ((i=0; i<${PACKAGES_REQUIRED__LEN:-0}; i++)); do
        local var="PACKAGES_REQUIRED_${i}"
        pkg="${!var}"
        PACKAGES="$PACKAGES $pkg"
    done
    PACKAGES="$(echo "$PACKAGES" | xargs)"

    AUR_PACKAGES=""
    for ((i=0; i<${PACKAGES_AUR__LEN:-0}; i++)); do
        local var="PACKAGES_AUR_${i}"
        pkg="${!var}"
        AUR_PACKAGES="$AUR_PACKAGES $pkg"
    done
    AUR_PACKAGES="$(echo "$AUR_PACKAGES" | xargs)"

    if [[ -n "$PACKAGES" && -z "${PACMAN_PACKAGES:-}" ]]; then
        PACMAN_PACKAGES="$PACKAGES"
    fi

    GIT_REPOSITORIES=""
    local repo_count="${GIT_REPOSITORIES__LEN:-0}"
    for ((i=0; i<repo_count; i++)); do
        local url_var="GIT_REPOSITORIES_${i}_URL"
        local path_var="GIT_REPOSITORIES_${i}_PATH"
        local url="${!url_var}"
        local path="${!path_var}"
        if [[ -n "$url" && -n "$path" ]]; then
            GIT_REPOSITORIES="$GIT_REPOSITORIES"$'\n'"$url|$path"
        fi
    done

    COPY_ITEMS=""
    local copy_count="${CONFIG_COPY_ITEMS__LEN:-0}"
    for ((i=0; i<copy_count; i++)); do
        local var="CONFIG_COPY_ITEMS_${i}"
        local item="${!var}"
        if [[ -n "$item" ]]; then
            IFS='|' read -r src dst <<< "$item"
            COPY_ITEMS="$COPY_ITEMS"$'\n'"$src|$dst"
        fi
    done

    PACKAGE_ROOT="${CONFIG_PAYLOAD_ROOT:-}"
    CONFIG_ROOT="${CONFIG_INSTALL_PATH:-}"
}

config_parse_toml_bash() {
    local file="$1"
    local section=""
    local line key value raw

    while IFS= read -r line || [[ -n "$line" ]]; do
        raw="${line#"${line%%[![:space:]]*}"}"
        [[ -z "$raw" || "$raw" == \#* ]] && continue

        if [[ "$raw" == \[*\] ]]; then
            section="$(echo "$raw" | sed 's/^\[//;s/\]$//')"
            continue
        fi

        if [[ "$raw" == *=* ]]; then
            key="${raw%%=*}"
            value="${raw#*=}"
            key="$(echo "$key" | xargs)"
            value="$(echo "$value" | xargs)"

            local var_base
            if [[ -n "$section" ]]; then
                var_base="$(echo "${section}.${key}" | tr 'a-z.-' 'A-Z__')"
            else
                var_base="$(echo "$key" | tr 'a-z' 'A-Z')"
            fi

            if [[ "$value" == \"*\" ]]; then
                value="${value#\"}"
                value="${value%\"}"
                printf -v "$var_base" '%s' "$value"
            elif [[ "$value" == \[*\] ]]; then
                local list_content="${value#\[}"
                list_content="${list_content%\]}"
                local items item
                IFS=',' read -ra items <<< "$list_content"
                local idx=0
                for item in "${items[@]}"; do
                    item="$(echo "$item" | xargs)"
                    item="${item#\"}"
                    item="${item%\"}"
                    printf -v "${var_base}_${idx}" '%s' "$item"
                    ((idx++))
                done
                printf -v "${var_base}__LEN" '%d' "$idx"
            elif [[ "$value" == "true" ]]; then
                printf -v "$var_base" '%s' "true"
            elif [[ "$value" == "false" ]]; then
                printf -v "$var_base" '%s' "false"
            else
                printf -v "$var_base" '%s' "$value"
            fi
        fi
    done < "$file"
}
