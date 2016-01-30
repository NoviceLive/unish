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


# TODO: I prefer these.

upper_tr() {
    : "
Usage: upper_tr <string>

Convert the string to a uppercase one using 'tr'.

See Also: lower_tr, upper, lower
"
    local str="${1}"
    stdout "${str}" | tr "[:lower:]" "[:upper:]"
}


lower_tr() {
    : "
Usage: lower_tr <string>

Convert the string to a lowercase one using 'tr'.

See Also: upper_tr, upper, lower
"
    local str="${1}"
    stdout "${str}" | tr "[:upper:]" "[:lower:]"
}
