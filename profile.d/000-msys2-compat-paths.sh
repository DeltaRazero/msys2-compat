# Ensures user path variables are correctly set.

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

# Convert Windows paths to POSIX paths safely.
USERPROFILE=$(cygpath -u "$USERPROFILE")
APPDATA=$(cygpath -u "$APPDATA")
LOCALAPPDATA=$(cygpath -u "$LOCALAPPDATA")

# Add Windows profile paths.
case ":$PATH:" in
  *":$USERPROFILE/.local/bin:"*) ;;
  *) PATH="$USERPROFILE/.local/bin:$USERPROFILE/bin:$PATH" ;;
esac
# Add MSYS2 profile paths.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$HOME/bin:$PATH" ;;
esac
