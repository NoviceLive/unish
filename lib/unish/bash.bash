# Copyright 2015-2016 Gu Zhengxiong <rectigu@gmail.com>
#
# This file is part of Unish.
#
# Unish is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License
# as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Unish is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Unish.  If not, see <http://www.gnu.org/licenses/>.


shopt -s nullglob


Z() {
    zsh -c "$*"
}


command_not_found_handle() {
    404 "${@}"
    # if type _command_not_found_handler > /dev/null 2>&1; then
    #     _command_not_found_handler "${@}"
    # else
    #     return 127
    # fi
}


_func_decl() {
    builtin declare -f "${1}"
}


_type_name() {
    builtin type -t "${1}" || printf '%s\n' 'none'
}
