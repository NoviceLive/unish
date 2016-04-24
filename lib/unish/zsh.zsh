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


setopt null_glob


B() {
    bash -c "$*"
}


command_not_found_handler() {
    404 "${@}"
}


_func_decl() {
    debug "${1}"
    local decl
    decl=$(builtin whence -fx4 "$1")
    debug "${decl}"
    printf '%s\n' "${decl}"
}


_type_name() {
    debug "${1}"
    builtin whence -w "${1}" | cut -d' ' -f2
}
