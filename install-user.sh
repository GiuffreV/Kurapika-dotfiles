#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config/kurapika-backups/$(date +%Y%m%d-%H%M%S)"

backup_install() {
    local src="$1" dest="$2" relative

    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        relative="${dest#"$HOME"/}"
        mkdir -p "$BACKUP/$(dirname "$relative")"
        cp -a "$dest" "$BACKUP/$relative"
        echo "Backed up $dest"
    fi

    install -m 644 "$src" "$dest"
    echo "Installed $dest"
}

backup_install "$REPO/starship/starship.toml" \
    "$HOME/.config/starship.toml"
backup_install "$REPO/kitty/kitty.conf" \
    "$HOME/.config/kitty/kitty.conf"
backup_install "$REPO/fastfetch/assets/chains.webp" \
    "$HOME/.config/fastfetch/chains.webp"

mkdir -p "$HOME/.config/fastfetch"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

sed "s|__FASTFETCH_LOGO__|$HOME/.config/fastfetch/chains.webp|g" \
    "$REPO/fastfetch/config.jsonc" > "$tmp"

dest="$HOME/.config/fastfetch/config.jsonc"
if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP/.config/fastfetch"
    cp -a "$dest" "$BACKUP/.config/fastfetch/config.jsonc"
    echo "Backed up $dest"
fi
install -m 644 "$tmp" "$dest"
echo "Installed $dest"

echo
echo "User theme installed."
echo "Backup directory: $BACKUP"
echo "Bash configuration is not automatically changed."
