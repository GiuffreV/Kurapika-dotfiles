#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "⛓ Kurapika Dotfiles Installer"
echo
echo "1) Install user theme"
echo "2) Install root Emperor Time theme"
echo "3) Install both"
echo "q) Quit"
read -r -p "Choose an option: " choice

case "$choice" in
  1)
    bash "$REPO/install-user.sh"
    ;;
  2)
    sudo bash "$REPO/install-root.sh"
    ;;
  3)
    bash "$REPO/install-user.sh"
    sudo bash "$REPO/install-root.sh"
    ;;
  q|Q)
    echo "Cancelled."
    exit 0
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac
