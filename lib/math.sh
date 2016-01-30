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


add() {
    : "
Usage: add number number ...

Add numbers."

    _reduce '+' "${@}"
}


sub() {
    : "
Usage: sub number number ...

Substract numbers."

    _reduce '-' "${@}"
}


mul() {
    : "
Usage: mul number number ...

Multiply numbers."

    _reduce '*' "${@}"
}


div() {
    : "
Usage: div number number ...

Divide numbers."

    _reduce '/' "${@}"
}


sec2min() {
    : "
Usage: sec2min number_of_seconds

Convert seconds to minutes.
"
    local sec="${1}"
    div "${sec}" 60.0
}


_reduce() {
    : "
Usage: _reduce <op> <arg> <arg> ...

Warning: There is no floating point support in the '$(())' of Bash.
"
    local op="${1}"
    local exp
    exp="$(printf '%s\n' "${@:2}" | paste -sd"${op}")"
    exp="${exp:-0}"
    debug "${exp}"
    printf '%s\n' "${exp}" | bc
}
