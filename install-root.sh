#!/usr/bin/env bash
set -euo pipefail

if (( EUID != 0 )); then
    echo "Run this script with sudo." >&2
    exit 1
fi

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_HOME="$(getent passwd root | cut -d: -f6)"
[[ -n "$ROOT_HOME" && -d "$ROOT_HOME" ]] || {
    echo "Could not determine root's home directory." >&2
    exit 1
}

BACKUP="$ROOT_HOME/.config/kurapika-backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$ROOT_HOME/.config"

backup_install() {
    local src="$1" dest="$2" relative

    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        relative="${dest#"$ROOT_HOME"/}"
        mkdir -p "$BACKUP/$(dirname "$relative")"
        cp -a "$dest" "$BACKUP/$relative"
        echo "Backed up $dest"
    fi

    install -m 644 "$src" "$dest"
    echo "Installed $dest"
}

backup_install "$REPO/starship/starship-emperor.toml" \
    "$ROOT_HOME/.config/starship-emperor.toml"
backup_install "$REPO/fastfetch/emperor.jsonc" \
    "$ROOT_HOME/.config/fastfetch/emperor-template.jsonc"

logo="$ROOT_HOME/.config/fastfetch/kurapika.png"
if [[ ! -f "$logo" ]]; then
    echo
    echo "Root logo not found at: $logo"
    read -r -p "Enter the absolute path to your logo, or leave blank to skip: " logo
fi

if [[ -n "$logo" ]]; then
    if [[ "$logo" != /* || ! -f "$logo" ]]; then
        echo "Logo path must be an existing file with an absolute path." >&2
        exit 1
    fi

    mkdir -p "$ROOT_HOME/.config/fastfetch"
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT
    sed "s|__FASTFETCH_LOGO__|$logo|g" \
        "$REPO/fastfetch/emperor.jsonc" > "$tmp"

    dest="$ROOT_HOME/.config/fastfetch/emperor.jsonc"
    if [[ -e "$dest" || -L "$dest" ]]; then
        mkdir -p "$BACKUP/.config/fastfetch"
        cp -a "$dest" "$BACKUP/.config/fastfetch/emperor.jsonc"
        echo "Backed up $dest"
    fi
    install -m 644 "$tmp" "$dest"
    echo "Installed $dest"
else
    echo "Skipped active Fastfetch config because no logo was supplied."
fi

bashrc="$ROOT_HOME/.bashrc"
touch "$bashrc"

if grep -q 'KURAPIKA_EMPEROR_TIME_BEGIN' "$bashrc"; then
    echo "Managed Emperor Time block already exists; leaving it unchanged."
elif grep -Eq 'starship-emperor\.toml|__kurapika_theme|emperor\.jsonc' "$bashrc"; then
    echo "Existing Emperor Time setup detected in root's .bashrc."
    echo "Not adding another initialization block."
    echo "Review the existing setup; the configs above are installed."
else
    cp -a "$bashrc" "$BACKUP/root.bashrc"
    cat >> "$bashrc" <<'BLOCK'

# KURAPIKA_EMPEROR_TIME_BEGIN
if [[ $- == *i* ]]; then
    if command -v starship >/dev/null 2>&1; then
        export STARSHIP_CONFIG="$HOME/.config/starship-emperor.toml"
        eval "$(starship init bash)"
    fi

    __kurapika_theme() {
        printf '\e]10;#FFFFFF\a'
    }
    case ";${PROMPT_COMMAND:-};" in
        *";__kurapika_theme;"*) ;;
        *) PROMPT_COMMAND="__kurapika_theme${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
    esac

    alias fastfetch='command fastfetch --config "$HOME/.config/fastfetch/emperor.jsonc"'
    if command -v fastfetch >/dev/null 2>&1 &&
       [[ -f "$HOME/.config/fastfetch/emperor.jsonc" ]]; then
        fastfetch
    fi
fi
# KURAPIKA_EMPEROR_TIME_END
BLOCK
    echo "Added managed Emperor Time block to $bashrc"
fi

# Ensure root login shells load .bashrc, without replacing existing login settings.
login_profile=""
for candidate in .bash_profile .bash_login .profile; do
    if [[ -f "$ROOT_HOME/$candidate" ]]; then
        login_profile="$ROOT_HOME/$candidate"
        break
    fi
done

if [[ -z "$login_profile" ]]; then
    cat > "$ROOT_HOME/.bash_profile" <<'PROFILE'
# Load Bash interactive configuration for login shells.
if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi
PROFILE
    chown root:root "$ROOT_HOME/.bash_profile"
    chmod 644 "$ROOT_HOME/.bash_profile"
    echo "Created $ROOT_HOME/.bash_profile"
elif grep -Eq '(^|[[:space:]])(source|\.)[[:space:]].*\.bashrc|\.bashrc' "$login_profile"; then
    echo "Login profile already references .bashrc: $login_profile"
else
    echo "Existing login profile does not visibly load .bashrc: $login_profile"
    echo "Leaving it unchanged to avoid altering existing shell behavior."
fi

chown root:root "$ROOT_HOME/.bashrc"
chmod 644 "$ROOT_HOME/.bashrc"

echo
echo "Root theme files installed."
echo "Backup directory: $BACKUP"
echo "Open a new root shell to test the theme."
