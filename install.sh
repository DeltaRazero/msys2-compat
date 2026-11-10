#!/usr/bin/bash

# Runs msys2-compat install scripts.

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

VERSION='1.0.0'
PROGRAM="msys2-compat/install.sh"

info() {
  printf '%s: %s\n' "$PROGRAM" "$*" >&1
}

warn() {
  printf '%s: %s\n' "$PROGRAM" "$*" >&2
}

die() {
  warn "$@"
  exit 1
}

# Check whether the current session is not running with elevated privileges.
if ! net session >/dev/null 2>&1; then
  # Clone the msys2-compat repository if it does not exist yet.
  if [ ! -d "/opt/msys2-compat" ]; then
    cd /opt || die "could not cd to /opt"
    git clone https://github.com/DeltaRazero/msys2-compat
    cd ./msys2-compat || die "could not cd to /opt/msys2-compat"
    # Configure git hooks so that pulling new updates triggers this script for
    # updating components.
    git config core.hooksPath .githooks
  else
    cd /opt/msys2-compat || die "could not cd to /opt/msys2-compat"
    git pull
  fi

  info "elevated privileges needed to continue setting up, expect a prompt"
  sleep 2

  if ! /opt/msys2-compat/bin/sudo /opt/msys2-compat/install.sh; then
    die "could not install msys2-compat.\n  If no sudo provider is available, see https://github.com/DeltaRazero/msys2-compat/blob/main/README#prerequisites"
  fi

  info "installation successful, reload your SHELL for the effects to apply"
  exit 0
fi

# From here on, this code should be running with 'sudo' (elevated privileges).

# Symlink files or symlinks recursively in /sym, where /sym is equivalent to
# the root of MSYS2.
SYM_DIR="/opt/msys2-compat/sym"
/usr/bin/find "$SYM_DIR" -type f,l 2>/dev/null | while IFS= read -r src; do
  dst="/${src#$SYM_DIR/}"
  mkdir -p "$(dirname "$dst")"
  MSYS="winsymlinks:nativestrict" ln -sfn "$src" "$dst"
done

# Execute all init scripts. Uses a new shell so that the path variables are
# correctly set.
INIT_SCRIPTS_DIR="/opt/msys2-compat/scripts/init"
if [ -d "$INIT_SCRIPTS_DIR" ]; then
  for script_fp in "$INIT_SCRIPTS_DIR"/*.sh; do
    [ -f "$script_fp" ] && /usr/bin/bash "$script_fp"
  done
fi
