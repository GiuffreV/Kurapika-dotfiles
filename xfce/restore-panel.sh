#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO/xfce/config/xfce4-panel.xml"
PANEL="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
STATUS="$HOME/.local/bin/status"
WALLPAPER="$HOME/Downloads/wallpapers/wp13276705-kurapika-pc-wallpapers.jpg"
STAGED="$HOME/.config/kurapika-staged/xfce4-panel.xml"
BACKUP="$HOME/.config/kurapika-backups/$(date +%Y%m%d-%H%M%S)"

[[ -f "$SOURCE" ]] || { echo "Missing panel template: $SOURCE" >&2; exit 1; }
[[ -f "$WALLPAPER" ]] || { echo "Missing wallpaper: $WALLPAPER" >&2; exit 1; }

for f in date htb lan target; do
    [[ -f "$REPO/xfce/scripts/status/$f" ]] ||
        { echo "Missing status script: $f" >&2; exit 1; }
done

mkdir -p "$BACKUP" "$STATUS" "$(dirname "$PANEL")" "$(dirname "$STAGED")"

if [[ -f "$PANEL" ]]; then
    cp -a "$PANEL" "$BACKUP/xfce4-panel.xml"
fi
xfconf-query -c xfce4-panel -lv > "$BACKUP/xfconf-panel-values.txt"

install -m 755 "$REPO"/xfce/scripts/status/* "$STATUS/"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
sed "s|\${HOME}|$HOME|g" "$SOURCE" > "$TMP"
xmllint --noout "$TMP"

install -m 600 "$TMP" "$STAGED"

echo "Status scripts installed."
echo "Panel XML validated and staged at:"
echo "  $STAGED"
echo "Backup saved at:"
echo "  $BACKUP"
echo
echo "Nothing has replaced the live panel configuration."
echo "To apply the staged XML, log out of XFCE completely first."
echo "From a TTY, run:"
printf '  install -m 600 %q %q\n' "$STAGED" "$PANEL"
echo "Then log back into XFCE."
