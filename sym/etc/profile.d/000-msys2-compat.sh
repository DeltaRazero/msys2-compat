# [POSIX-compatible shell version]

# Ensures path variables are correctly configured for using msys2-compat stuff.

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

# Already processed, so we can exit this file.
[[ ":$PATH:" == *":/opt/msys2-compat/bin:"* ]] && return

# Enforce to use nativestrict Windows symlinks.
# Check if the MSYS environment variable contains a 'winsymlinks:<value>' flag.
if grep -qE '(^|[[:space:]])winsymlinks:[^[:space:]]*' <<< "$MSYS"; then
  # Replace the existing winsymlinks value.
  MSYS=$(sed -E 's/(^|[[:space:]])winsymlinks:[^[:space:]]*/\1winsymlinks:nativestrict/g' <<< "$MSYS")
else
  # Pattern not found, so append or set the value.
  if [[ -z "$MSYS" ]];
    then MSYS="winsymlinks:nativestrict"
    else MSYS="$MSYS winsymlinks:nativestrict"
  fi
fi

# Ensure a non-login shell also sources this file.
_m2c_add_shellrc_sourcing() {
  local shell_name="$1"
  local shell_rc_fp="/etc/${shell_name}.${shell_name}rc"
  local shell_rc_script="source /etc/profile.d/000-msys2-compat.sh"
  # Inject sourcing this file in the shell RC.
  [[ ! -f "$shell_rc_fp" ]] && touch "$shell_rc_fp"
  if ! grep -q "^${shell_rc_script}$" "$shell_rc_fp"; then
    echo -e "\n# Source msys2-compat overrides.\n${shell_rc_script}" >> "$shell_rc_fp"
  fi
}
_m2c_add_shellrc_sourcing "${SHELL##*/}"
# Clean-up to not contaminate the actual shell environment.
unset _m2c_add_shellrc_sourcing

# Convert Windows paths to POSIX paths safely.
USERPROFILE=$(cygpath -u "$USERPROFILE")
APPDATA=$(cygpath -u "$APPDATA")
LOCALAPPDATA=$(cygpath -u "$LOCALAPPDATA")

# Add Windows profile paths.
[[ ":$PATH:" == *":$USERPROFILE/.local/bin:"* ]] || PATH="$USERPROFILE/.local/bin:$USERPROFILE/bin:$PATH"
# Add MSYS2 profile paths.
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Add overrides and utilities of msys2-compat prioritized at the front of PATH.
PATH="/opt/msys2-compat/bin:$PATH"
