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


lines_from_file() {
    local file="${1}"
    while read -r line; do
        printf '%s\n' "${line}"
    done < "${file}"
}


clone_many() {
    if [[ $# -lt 3 ]]; then
        return 1
    fi
    local base="${1}"
    local home="${2}"
    local many=("${@:3}")
    local name dest remote
    mkdir -p "${home}"
    for name in "${many[@]}"; do
        dest="${home}/$(basename "${name}")"
        if [[ -d "${dest}" ]]; then
            >&2 printf 'Already cloned: %s\n' "${name}"
        else
            remote="${base}${name}"
            >&2 printf 'Cloning %s\n' "${remote}"
            >&2 printf 'Dest: %s\n' "${dest}"
            git clone --recursive "${remote}" "${dest}"
        fi
    done
}
