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


# alias prm='sudo rm -rf build dist *.egg-info'

prm() {
    find -name '*.pyc' -delete && find -name '__pycache__' -delete
}


# TODO: I will not always leave this a no-op.
_command_not_found_handler() {
    printf 'command not found: %s\n' "$*" 1>&2
    return 127
}


unalias_if_exists cd

cd() {
    local LS_COUNT=50
    if [[ $# -eq 1 && -f "${1}" ]]; then
        local correction="$(realpath "$(dirname "${1}")")"
        info "Correcting to ${correction}"
        builtin cd "${correction}"
    else
        builtin cd "${@}"
    fi

    if [[ -d .git ]]; then
        git status
    elif [[ -d .hg ]]; then
        hg status
    else
        local total=$(ls -a | wc -l)
        info "Total ${total} items."
        if [[ ${total} -lt ${LS_COUNT} ]]; then
            command ls -a --color=always
        fi
    fi
}


unalias_if_exists a

a() {
    : "
Usage: a

Attach to a recent Tmux session or create a new one if none exists.
"
    if [[ -z $TMUX ]]; then
        if tmux list-sessions > /dev/null 2>&1; then
            info 'Attaching to the Most Recent Session...'
            tmux attach-session
        else
            info 'Creating Tmux Session main...'
            tmux new-session -s main
            info 'Created Tmux Session main.'
        fi
    else
        error "Already Attached to ${TMUX}" && return 1
    fi
}

if exists tmux; then
    if [[ -z $TMUX ]]; then
        info 'Starting Tmux...'
        a
        info 'Started Tmux.'
    else
        info 'Already Started Tmux.'
    fi
else
    warning 'Tmux Unavailable.'
fi


unalias_if_exists u

u() {
    local one
    for one in ./*.git; do
        upgit "${one}"
    done
    for one in ./*.hg; do
        uphg "${one}"
    done
    for one in ./*.svn; do
        upsvn "${one}"
    done
    return 0

    sudo pacman --sync --refresh --refresh --sysupgrade
}


unalias_if_exists g

g() {
    if [[ "$1" == "cl" || "$1" == "i" || "$1" == "h" ]]; then
        git "$@"
        return 0
    fi
    _repo_handler "$@" || lsgit
}


unalias_if_exists h

h() {
    if [[ "$1" == "cl" || "$1" == "i" || "$1" == "h" ]]; then
        hg "$@"
        return 0
    fi
    _repo_handler "$@" || lshg
}


_repo_handler() {
    if hg status > /dev/null 2>&1; then
        hg "$@"
    elif git status > /dev/null 2>&1; then
        git "$@"
    else
        return 233
    fi
}


unalias_if_exists ls

ls() {
    : "
Usage: ls <name> <options>

Pass control to 'less' if the first argument is a file,
and otherwise pass control to the real 'ls'.
"
    local name="${1}"
    if [[ -f "${name}" ]]; then
        less -FX "${name}"
    else
        /usr/bin/env ls --color=auto "${@}"
    fi
}


unalias_if_exists e

e() {
    : "
Usage: e <name> <options>

Open an existing file using Emacs or create a new one using t.
"
    local name="${1}"
    local templator=ttouch
    if [[ -f "${name}" ]]
    then
        emacs "${name}" &
    elif exists ${templator}; then
        ${templator} "${@}" \
            || warning "The File '${name}' is not Templated"
        emacs "${name}" &
    else
        warning "${templator} Unavailable"
        emacs "${name}" &
    fi
}
