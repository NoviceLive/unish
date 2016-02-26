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


enum() {
    : "
Usage: enum <name> <name> ...

Create enumerated constants counting from 0.
"
    local i=0
    local one
    for one in "$@"; do
        typeset -gr ${one}=${i}
        ((i+=1))
    done
}


relative_to() {
    : "
Usage: relative_to <name> <start>

Make a relative path.
"
    local name="${1}"
    local start="${2}"
    printf '%s\n' "$(realpath --relative-to "${start}" "${name}")"
}


_generic_caller_name() {
    local index="${1}"
    local callers=("${@:2}")
    local caller="${callers[${index}]}"
    if [[ -f "${caller}" ]]; then
        caller="$(relative_to "${caller}" "${UNISH}")"
    fi
    printf '%s\n' "${caller}"
}


make_see_also() {
    : "
Usage: make_see_also <current> <maker> <all>

Make a See Also string used in function definition.
"
    local current="${1}"
    local alg="${2}"
    local all=("${@:3}")
    local see_also
    see_also=$(for i in "${all[@]}"; do
                   if [[ "${i}" != "${current}" ]]; then
                       printf '%s\n' "$($alg "${i}")"
                   fi
               done)
    see_also=$(intersperse ', ' "${see_also[@]}")
    printf '%s\n' "${see_also[@]}"
}


intersperse() {
    local delim="${1}"
    local strs=("${@:2}")
    printf '%s\n' "${strs[@]}" | paste -sd',' | sed "s/,/${delim}/g"
}


_log_levels=(DEBUG INFO WARNING ERROR CRITICAL)

enum "${_log_levels[@]}"

export LOG_LEVEL=$INFO

for one in "${_log_levels[@]}"; do
    eval "
${one:0:1}() {
    : \"
Usage: ${one[1]}

Change the log level to $one.
\"
    export LOG_LEVEL=\$$one
}
"
done


# debug warning error critical <- _log_generic <- _log_real
# info <- _log_real


_log_real() {
    local parent="${1}"
    local message="${2}"
    printf "to ${BYel}STDERR${RCol} from ${BBlu}%s${RCol}: %s\n" \
           "${parent}" "${message}" 1>&2
}

_colorize_level_name() {
    local name="${1}"
    local priv="${2}"
    local index=$((priv + 1))
    local schemes=(${BYel} ${BGre} ${BPur} ${BRed} ${BRed})
    printf "${schemes[${index}]}%s${RCol} " "${name}" 1>&2
}

_log_generic() {
    local name="${1}"
    local priv="${2}"
    local message="${3}"
    if [[ ${LOG_LEVEL} -le ${priv} ]]; then
        local parent
        parent="$(pparent_name)"
        if [[ -z "${parent}" ]]; then
            parent='interactive'
        fi
        _colorize_level_name "${name}" "${priv}"
        _log_real "${parent}" "${message}"
    fi
}


for one in "${_log_levels[@]}"; do
    see_also=$(make_see_also "${one}" lower \
                             "${_log_levels[@]}")
    if [[ $one != "INFO" ]]; then
        name=$(lower "${one}")
        eval "
$name() {
    : \"
Usage: $name <message> <message> ...

Write $one messages to standard error stream.

See Also: ${see_also}
\"
    _log_generic $one \$$one \"\$*\"
}
"
    fi
done


info() {
    : "
Usage: info <message> <message> ...

Write INFO messages to standard error stream.

When used interactively, it will pass control to /usr/bin/info.

See Also: debug, warning, error, critical
"
    local parent
    parent="$(parent_name)"
    if [[ -z "${parent}" ]]; then
        /usr/bin/env info "${@}"
        return 0
    fi
    if [[ $LOG_LEVEL -le ${INFO} ]]; then
        _colorize_level_name "INFO" ${INFO}
        _log_real "${parent}" "${*}"
    fi
}
