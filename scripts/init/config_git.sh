#!/usr/bin/bash

# Set up git to work in both MSYS2 shells and when called natively from Windows
# shells (CMD or PowerShell).

# msys2-compat
# Copyright (C) 2026 DeltaRazero
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

PROGRAM="msys2-compat/${0##*/}"

info() {
  printf '%s: %s\n' "$PROGRAM" "$*" >&1
}

# Enable Windows' native SSH agent.
info "enabling Windows SSH agent"
powershell -Command "Get-Service -Name ssh-agent | Set-Service -StartupType Automatic"
powershell -Command "Start-Service ssh-agent"

# Configure MSYS2's git to use Windows' native OpenSSH.
info "configuring git to use Windows' OpenSSH"
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"

# Create SSH directory in the Windows user profile home. This needs to be the
# storage location to prevent ownership errors when natively calling git from
# Windows shells (CMD or PowerShell).
USERPROFILE_SSH_DIR="$USERPROFILE/.ssh"
mkdir -p "$USERPROFILE_SSH_DIR"

MSYS2_SSH_DIR="$HOME/.ssh"
# Don't have to move anything over if already a symlink.
if [[ ! -h "$MSYS2_SSH_DIR" ]]; then
  # Move over contents from the user MSYS2 home directory.
  if [[ -d "$MSYS2_SSH_DIR" ]]; then
    info "moving .ssh contents"
    for item in "$MSYS2_SSH_DIR"/*; do
      # Handle empty directory safely.
      [[ -e "$item" ]] || continue

      name=$(basename "$item")
      dst="$USERPROFILE_SSH_DIR/$name"

      # Check if the file or directory already exists at the destination folder.
      if [[ -e "$dst" ]]; then
        dst="${dst}_msys2.bak"
        info "conflict: '$name' already exists at $USERPROFILE_SSH_DIR"
        info "  -> renaming to '${name}_msys2.bak'. Please check and merge manually."
      fi

      info "moving $item -> $dst"
      mv "$item" "$dest"
    done

    # Remove the old MSYS2 SSH directory.
    rm -rf "$MSYS2_SSH_DIR"
  fi

  info "creating symlink $MSYS2_SSH_DIR -> $USERPROFILE_SSH_DIR"
  ln -s "$USERPROFILE_SSH_DIR" "$MSYS2_SSH_DIR"
fi
