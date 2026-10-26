#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config/kurapika-backups/$(date +%Y%m%d-%H%M%S)"

backup_and_install() {
    local src="$1"
    local dest="$2"
    local relative backup_dest

    mkdir -p "$(dirname "$dest")"

    if [[ -e "$dest" || -L "$dest" ]]; then
        relative="${dest#"$HOME"/}"
        backup_dest="$BACKUP/$relative"
        mkdir -p "$(dirname "$backup_dest")"
        cp -a "$dest" "$backup_dest"
        echo "Backed up: $dest -> $backup_dest"
    fi

    install -m 644 "$src" "$dest"
    echo "Installed: $dest"
}

echo "Kurapika dotfiles installer"
echo "Backups: $BACKUP"
read -r -p "Install user configs? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }

backup_and_install "$REPO/starship/starship.toml" \
    "$HOME/.config/starship.toml"

backup_and_install "$REPO/kitty/kitty.conf" \
    "$HOME/.config/kitty/kitty.conf"

backup_and_install "$REPO/fastfetch/assets/chains.webp" \
    "$HOME/.config/fastfetch/chains.webp"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

sed "s|__FASTFETCH_LOGO__|$HOME/.config/fastfetch/chains.webp|g" \
    "$REPO/fastfetch/config.jsonc" > "$TMP"

mkdir -p "$HOME/.config/fastfetch"
if [[ -e "$HOME/.config/fastfetch/config.jsonc" ||
      -L "$HOME/.config/fastfetch/config.jsonc" ]]; then
    mkdir -p "$BACKUP/.config/fastfetch"
    cp -a "$HOME/.config/fastfetch/config.jsonc" \
        "$BACKUP/.config/fastfetch/config.jsonc"
    echo "Backed up: $HOME/.config/fastfetch/config.jsonc"
fi

install -m 644 "$TMP" "$HOME/.config/fastfetch/config.jsonc"
echo "Installed: $HOME/.config/fastfetch/config.jsonc"

echo
echo "User theme installed."
echo "Review bash/bashrc manually before merging it into ~/.bashrc."
echo "Root Emperor Time is separate; do not run this installer with sudo."
