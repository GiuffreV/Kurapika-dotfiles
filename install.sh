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
  1|2|3)
    missing=()
    required_commands=()

    case "$choice" in
      1) required_commands=(starship fastfetch kitty) ;;
      2) required_commands=(starship fastfetch) ;;
      3) required_commands=(starship fastfetch kitty) ;;
    esac

    for cmd in "${required_commands[@]}"; do
      command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done

    if ((${#missing[@]})); then
      . /etc/os-release
      echo
      echo "Missing required commands: ${missing[*]}"

      case "${ID:-}" in
        arch)
          echo "On Arch Linux, install dependencies with:"
          echo "  sudo pacman -S --needed starship fastfetch kitty"
          ;;
        kali|debian|ubuntu|linuxmint)
          echo "On Kali/Debian-based systems, try:"
          echo "  sudo apt update"
          echo "  sudo apt install starship fastfetch kitty"
          echo "Package availability varies by release."
          ;;
        *)
          echo "Install Starship, Fastfetch, and Kitty using your distro's package manager."
          ;;
      esac

      echo "Install the missing dependencies, then rerun this installer."
      exit 1
    fi
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
esac
