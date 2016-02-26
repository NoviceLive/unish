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


bashcheck() {
    : "
Usage: bashcheck <options> <arguments>

Check Bash script using shellcheck.

With the following excluded.

SC1090: Can't follow non-constant source. Use a directive to specify location.
"
    shellcheck "${@}" --shell=bash --exclude=SC1090
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


SSH_AGENT="$HOME/.ssh/ssh_agent"

_start_ssh_agent() {
    mkdir -p ~/.ssh
    ssh-agent > "$SSH_AGENT" && chmod 600 "$SSH_AGENT"
    source "$SSH_AGENT" > /dev/null
}

if pgrep ssh-agent > /dev/null 2>&1; then
    source "$SSH_AGENT" > /dev/null 2>&1 || _start_ssh_agent
    if ssh-add -l > /dev/null; then
        for one in $(ssh-add -l | cut -d' ' -f3); do
            info "Found ssh-agent managed key ${one}."
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
~/.ssh/id_rsa-bandwagon
"
    if [[ $# -ne 0 ]]; then
        keys=("$@")
    else
        # TODO: Hardcoded defaults.
        keys=($HOME/.ssh/id_rsa-{bitbucket,github,bandwagon})
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
