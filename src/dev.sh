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


pylint() {
    : "
Lint Python code using pylint with some warnings disabled
and display results using a pager if necessary.
"
    command pylint "${@}" \
            --disable 'too-few-public-methods,missing-docstring' \
            --disable 'bad-builtin' \
        | less -FXR
}


bashcheck() {
    : "
Usage: bashcheck <options> <arguments>

Check Bash script using shellcheck.

With the following excluded.

SC1090: Can't follow non-constant source. Use a directive to specify location.
"
    shellcheck "${@}" --shell=bash --exclude=SC1090 | less -FXR
}


dog() {
    : "
Colorized cat.

Usage: dog <file>
"
    if [[ $# -ne 1 ]]; then
        error "One argument for the file name to view!"
        return 1
    fi
    if exists highlight; then
        debug "Using highlight"
        highlight -O xterm256 --style breeze --line-numbers "$1" \
            | less -FXR
    elif exists pygmentize; then
        debug "Using pygmentize"
        pygmentize -g -O style=colorful,linenos=1 "$1" | less -FXR
    else
        error "No highlighter available"
        info "Try installing 'highlight' or 'pygmentize'"
        return 1
    fi
}


mkinc() {
    local dir="${1:-$PWD}"
    debug "Searching for headers in: ${dir}"
    find "${dir}" -type f -name '*.h' | while read -r filename; do
        stdout "# include <$(relative_to "${filename}" "${dir}")>"
    done
}


cuddle() {
    : "
Cuddle brackets.

Usage: cuddle <file> <file> ...
"
    perl -i -pe "s/(?<=\(\))\n/ /g" "${@}"
}


mdlink() {
    : "
List Markdown links in files.

Usage: mdlink <file> <file> ...
"
    grep -oP '\*\s\[.+?\]\(.+?\)' "${@}"
}


lssc() {
    : "
List syscall definitions in files.

Usage: lssc <file> <file> ...
"
    grep -zoP '(?s)SYSCALL_DEFINE\d\(.+?(?=[#{])' "${@}"
}


SSH_AGENT="$HOME/.ssh/agent"

_start_ssh_agent() {
    mkdir -p ~/.ssh
    ssh-agent > "$SSH_AGENT" && chmod 600 "$SSH_AGENT"
    source "$SSH_AGENT" > /dev/null
}

if pgrep ssh-agent > /dev/null 2>&1; then
    source "$SSH_AGENT" > /dev/null 2>&1 || _start_ssh_agent
    if ssh-add -l > /dev/null; then
        for one in $(ssh-add -l | cut -d' ' -f3); do
            info "Managed SSH Key: ${one}."
        done
    fi
else
    if exists ssh-agent; then
        _start_ssh_agent
    else
        error 'ssh-agent Unavailable!'
    fi
fi

addkey() {
    : "
Usage: addkey [<key> <key> ...]

Add keys to ssh-agent.
Without an argument, it will try the following.

~/.ssh/id_rsa-bitbucket
~/.ssh/id_rsa-github
"
    if [[ $# -ne 0 ]]; then
        keys=("$@")
    else
        # TODO: Hardcoded defaults.
        keys=($HOME/.ssh/id_rsa-{bitbucket,github})
    fi
    if pgrep ssh-agent > /dev/null 2>&1; then
        source "$SSH_AGENT" > /dev/null 2>&1
        for one in "${keys[@]}"; do
            if [[ -f ${one} ]]; then
                info "Adding key to ssh-agent: ${one}"
                ssh-add "$one"
            fi
        done
        ssh-add -l
    fi
}


lskey() {
    : "
List keys managed by ssh-agent.

Usage: lskey
"
    ssh-add -l
}
