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

# Install the bundled wallpaper in a portable location.
WALLPAPER_SOURCE="$REPO/wallpapers/kurapika.jpg"
WALLPAPER_DEST="$HOME/.local/share/backgrounds/kurapika.jpg"

if [[ -f "$WALLPAPER_SOURCE" ]]; then
    mkdir -p "$(dirname "$WALLPAPER_DEST")"
    if [[ -e "$WALLPAPER_DEST" || -L "$WALLPAPER_DEST" ]]; then
        mkdir -p "$BACKUP/.local/share/backgrounds"
        cp -a "$WALLPAPER_DEST" "$BACKUP/.local/share/backgrounds/kurapika.jpg"
        echo "Backed up $WALLPAPER_DEST"
    fi
    install -m 644 "$WALLPAPER_SOURCE" "$WALLPAPER_DEST"
    echo "Installed $WALLPAPER_DEST"

    # Apply it to every existing XFCE monitor/workspace wallpaper property.
    if command -v xfconf-query >/dev/null 2>&1 &&
       [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
        mapfile -t wallpaper_props < <(
            xfconf-query -c xfce4-desktop -l 2>/dev/null |
            grep '/last-image$' || true
        )

        if ((${#wallpaper_props[@]})); then
            for prop in "${wallpaper_props[@]}"; do
                xfconf-query -c xfce4-desktop -p "$prop" \
                    -s "$WALLPAPER_DEST"
            done
            echo "Applied wallpaper to ${#wallpaper_props[@]} XFCE setting(s)."
        else
            echo "Wallpaper installed; no existing XFCE wallpaper properties were found."
        fi
    else
        echo "Wallpaper installed. Apply it after logging into XFCE."
    fi
else
    echo "Bundled wallpaper missing: $WALLPAPER_SOURCE" >&2
    echo "Skipping wallpaper installation." >&2
fi

echo
echo "User theme installed."
echo "Backup directory: $BACKUP"
echo "Bash configuration is not automatically changed."
