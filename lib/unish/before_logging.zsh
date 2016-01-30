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


upper() {
    : "
Usage: upper <string>

Convert the string to a uppercase one.

See Also: lower, upper_tr, lower_tr
"
    local var="$1"
    printf '%s\n' "${var:u}"
}


lower() {
    : "
Usage: lower <string>

Convert the string to a lowercase one.

See Also: upper, upper_tr, lower_tr
"
    local var="$1"
    printf '%s\n' "${var:l}"
}


# unish_caller_name (+1) <- _generic_caller_name

unish_caller_name() {
    : "
Usage: unish_caller_name <index>

Get the caller at the specified index.
"
    local index=$1
    index=$((index+1))
    printf '%s\n' "$(_generic_caller_name $index "${funcstack[@]}")"
}


# parent_name <- unish_caller_name <- _generic_caller_name

parent_name() {
    : "
Usage: parent_name

Get the parent.
"
    unish_caller_name 3
}


# pparent_name <- unish_caller_name <- _generic_caller_name

pparent_name() {
    : "
Usage: pparent_name

Get the parent of the parent.
"
    unish_caller_name 4
}
