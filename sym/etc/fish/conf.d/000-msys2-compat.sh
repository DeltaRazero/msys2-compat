# [Fish shell version]

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
if contains /opt/msys2-compat/bin $PATH
  return
end

# Enforce to use nativestrict Windows symlinks.
# Check if the MSYS environment variable contains a 'winsymlinks:<value>' flag.
if string match -qr '(^|[[:space:]])winsymlinks:[^[:space:]]*' -- "$MSYS"
  # Replace the existing winsymlinks value.
  set -gx MSYS (string replace -r '(^|[[:space:]])winsymlinks:[^[:space:]]*' '$1winsymlinks:nativestrict' -- "$MSYS")
else
  # Pattern not found, so append or set the value.
  if test -z "$MSYS"
    set -gx MSYS "winsymlinks:nativestrict"
  else
    set -gx MSYS "$MSYS winsymlinks:nativestrict"
  end
end

# NOTE: Fish automatically sources all *.fish files in /etc/fish/conf.d/ for
# both login and non-login interactive shells natively. Therefore, the manual
# shell RC injection logic is unnecessary here.

# Convert Windows paths to POSIX paths safely.
set -gx USERPROFILE (cygpath -u $USERPROFILE)
set -gx APPDATA (cygpath -u $APPDATA)
set -gx LOCALAPPDATA (cygpath -u $LOCALAPPDATA)

# Add Windows profile paths.
if not contains $USERPROFILE/bin $PATH
  set -gx PATH $USERPROFILE/bin $PATH
  set -gx PATH $USERPROFILE/.local/bin $PATH
end
# Add MSYS2 profile paths.
if not contains $HOME/bin $PATH
  set -gx PATH $HOME/bin $PATH
  set -gx PATH $HOME/.local/bin $PATH
end

# Add overrides and utilities of msys2-compat prioritized at the front of PATH.
if not contains /opt/msys2-compat/bin $PATH
  set -gx PATH /opt/msys2-compat/bin $PATH
end
