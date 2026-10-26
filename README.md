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

## Install user terminal configs

Clone the repository, enter its directory, and run:

```bash
./install.sh
```

Review the files before installation. Existing configuration files should
be backed up before they are replaced.

The installer does not install the root Emperor Time configuration or
automatically replace your Bash configuration.

## Root Emperor Time theme

`bash/root-bashrc`, `starship/starship-emperor.toml`, and
`fastfetch/emperor.jsonc` are separate root-theme configuration files.
Review and merge them into the appropriate root configuration manually.
Do not run the user installer with `sudo`.

The root Fastfetch configuration uses a `__FASTFETCH_LOGO__` placeholder.
Set it to the path of your own logo before using that configuration.

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
