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


exists() {
    : "
Usage: exists <command>

Determine whether the command is available or not.

Examples:

$ exists exists
$ exists which
$ exists pygmentize

"
    command which "$1" > /dev/null 2>&1
}


stdout() {
    : "
Usage: stdout <message>

Write a message to STDOUT appending a newline.
"
    local message="${1}"
    printf '%s\n' "${message}"
}


get_distro() {
    : "
Get the name of the distribution as returned by 'lsb_release -si'.

Examples:

$ get_distro
Arch
"
    local name
    if exists lsb_release; then
        debug "Using lsb_release"
        printf "$(lsb_release --short --id)"
    else
        debug "Using special files"
        if [[ -f /etc/arch-release ]]; then
            name="Arch"
        elif [[ -f /etc/debian_version ]]; then
            name="Debian"
        fi
    fi
    stdout "${name}"
}


source_if_exists() {
    : "
Usage: source_if_exists <name>

Source the file if it exists.
"
    local name="${1}"
    if [[ -f "${name}" ]]; then
        info "Sourcing ${name}"
        source "${name}"
    else
        error "No such file: ${name}"
        return 1
    fi
}


unalias_if_exists() {
    : "
Usage: unalias_if_exists <name>

Remove the alias if it exists.
"
    local name="${1}"
    { unalias "${name}" 2>&1; } > /dev/null && \
        warning "Unaliased: ${name}"
}


_is_generic() {
    debug "$*"
    local expected="${1}"
    local real
    real=$(_type_name "$2")
    debug "_type_name returned '${real}' and expecting '${expected}'"
    [[ "${real}" == "${expected}" ]]
}


is_func() {
    : "
Usage: is_func <name>

Determine whether the name is a shell function or not.
"
    local name="${1}"
    _is_generic 'function' "${name}"
}


is_builtin() {
    : "
Usage: is_builtin <name>

Determine whether the name is a shell builtin or not.
"
    local name="${1}"
    _is_generic 'builtin' "${name}"
}


_get_docs() {
    debug "$1"
    local docs
    docs=$(printf '%s' "$1" | grep -ozP '(?s)(?<=: ").+?(?=")')
    if [[ $(printf '%s' "$docs" | wc -l) -eq 0 ]]; then
        docs=$(printf '%s' "$1" | grep -ozP '(?s)(?<=doc=").+?(?=")')
        if [[ $(printf '%s' "$docs" | wc -l) -eq 0 ]]; then
            docs="doc not found"
        fi
    fi
    printf '%s' "$docs"
}


info 'Starting Help System...'

help() {
    : "
Usage: help <function_name>

Show the documentation on the specified function.

Examples:

$ help help
$ help cd
$ help pwd
"
    local one
    for one in "$@"; do
        if is_builtin "${one}"; then
            debug "${one} is builtin"
            if [[ ${CURRENT_SHELL} == "zsh" ]]; then
                debug "Running 'run-help' for Zsh"
                run-help "${one}"
            elif [[ ${CURRENT_SHELL} == "bash" ]]; then
                debug "Running 'builtin help' for Bash"
                builtin help "${one}"
            fi
        elif is_func "${one}"; then
            info ">>> Help on function: ${one} <<<"
            printf '%s\n\n' "$(_get_docs "$(_func_decl "${one}")")" \
                   | less -FXR
        else
            error "${one} is not a function"
        fi
    done
}

info 'Started Help System.'
