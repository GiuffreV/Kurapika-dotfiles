# Kurapika Dotfiles

My personal Arch Linux + XFCE configuration inspired by Kurapika from
Hunter × Hunter. The normal terminal theme uses subdued colors; root's
separate Emperor Time theme uses crimson accents.

## Contents

- `bash/` — user and root Bash configuration examples
- `fastfetch/` — Fastfetch configs and chain artwork
- `fonts/` — custom Kurapika prompt font
- `kitty/` — Kitty terminal configuration
- `starship/` — normal and Emperor Time prompts
- `xfce/` — XFCE settings snapshots, panel template, and status scripts
- `install.sh` — installer for selected user-level terminal configs

## Requirements

- Arch Linux or a similar Linux distribution
- Bash
- Kitty
- Starship
- Fastfetch
- XFCE, if restoring the desktop panel
- `xmllint`, for validating the saved panel XML

Install the required applications separately using your preferred package
manager.

## Install

Run the interactive installer from the repository directory:

```bash
./install.sh
```

Choose the user theme, root Emperor Time theme, or both. The root option
uses sudo. Do not run the main installer itself with sudo.

The installer backs up existing configuration files before replacing them.
It installs the root Starship and Fastfetch configs automatically and
uses `/root/.config/fastfetch/kurapika.png` when available. If no logo
exists there, it asks for an absolute path.

If root's `.bashrc` already contains Emperor Time setup, the installer
does not append a duplicate initialization block. Review that existing
setup if necessary.

The installer does not automatically change the XFCE panel; use
`xfce/restore-panel.sh` separately and follow its instructions.

## Root Emperor Time theme

The root setup uses `starship/starship-emperor.toml`,
`fastfetch/emperor.jsonc`, and `bash/root-bashrc` as its reference
configuration. `install-root.sh` installs the active Starship and
Fastfetch configs and adds a managed Bash block when needed.

The existing root Bash configuration is backed up before the managed
block is added. Existing unrelated settings are preserved.

## XFCE panel restoration

The saved panel template references a wallpaper at:

`~/Downloads/wallpapers/wp13276705-kurapika-pc-wallpapers.jpg`

The wallpaper is not included in this repository. Place your own copy at
that path or update the saved panel XML to point to your wallpaper.

The status scripts are in `xfce/scripts/status/`. The panel template
references them under `~/.local/bin/status/`.

Review `xfce/restore-panel.sh` before running it. Back up your current
XFCE settings first. Applying a saved panel configuration should be done
only after logging out of the XFCE session, because XFConf may overwrite
configuration files when the session is active.

## Notes

These are personal configuration files. Inspect paths and commands before
using them on another machine. No credentials, VPN profiles, or private
keys should be committed.
