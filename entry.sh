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


typeset -xr VERSION_STRING='Unish-0.0.1'

printf '%s\n\n' "This is ${VERSION_STRING}."


log_simple() {
    : "
Usage: log_simple <message>

Write a simple LOGGING message to STDERR.
"
    printf "LOGGING to STDERR: %s\n" "${*}" 1>&2
}


log_simple "Starting Version ${VERSION_STRING}."


typeset -xr CURRENT_SHELL=$(ps --pid $$ --format comm=)

log_simple "Exported CURRENT_SHELL to ${CURRENT_SHELL}."


_get_self_dir_generic() {
    local self_dir="$1"
    log_simple "Found Candidate $self_dir."
    local real_dir
    real_dir="$(realpath -- "$self_dir")"
    printf '%s\n' "$(dirname -- "$real_dir")"
}


_get_self_dir_zsh() {
    : "
Usage: _get_self_dir_zsh

Obtain the location of the current script for Zsh.

Warning: You MUST invoke it on the TOP LEVEL in the SHELL SCRIPT.
"
    local self_dir="${funcstack[2]}"
    if [[ -z "${self_dir}" ]]; then
        log_simple "Failed to Found Candidate for Zsh."
        return 1
    fi
    _get_self_dir_generic "${self_dir}"
}


_get_self_dir_bash() {
    local self_dir="${BASH_SOURCE[0]}"
    if [[ -z "${self_dir}" ]]; then
        log_simple "Failed to Found Candidate for Bash."
        return 1
    fi
    _get_self_dir_generic "${self_dir}"
}


if [[ "${CURRENT_SHELL}" == 'zsh' ]]; then
    typeset -xr UNISH="$(_get_self_dir_zsh)"
    if [[ -z "${UNISH}" ]]; then
        log_simple "Failed to Locate Unish. Aborting..."
        return 1
    fi
elif [[ "${CURRENT_SHELL}" == 'bash' ]]; then
    typeset -xr UNISH="$(_get_self_dir_bash)"
fi

log_simple "Exported UNISH to ${UNISH}."


log_simple 'Starting Logging System...'

source "$UNISH"/lib/unish/before_logging."${CURRENT_SHELL}"
source "$UNISH"/lib/logging.sh

info 'Started Logging System.'


reexec() {
    : "
Usage: reexec

Reload the shell and Unish.
"
    builtin exec /usr/bin/env "${CURRENT_SHELL}"
}


for one in reload rl re; do
    eval "
${one}() {
    : \"
Usage: ${one}

Reload the shell and Unish.
\"
    reexec
}
"
done


source "$UNISH"/lib/unish/"${CURRENT_SHELL}"."${CURRENT_SHELL}"
info 'Reached Target Unish Environment.'


info 'Starting Unish Base...'

source "$UNISH"/lib/meta.sh


for one in math str media file shellcoding; do
    source_if_exists "$UNISH"/lib/$one.sh
done


for one in dev smart misc; do
    source_if_exists "$UNISH"/src/$one.sh
done

info 'Started Unish Base.'


export PATH=$PATH:$HOME/bin:$HOME/bin/lnk:$HOME/.local/bin


export VISUAL='emacs -nw'
export EDITOR="$VISUAL"


ulimit -c unlimited


info 'Starting Plugins...'

source "${UNISH}/plugins/common.sh"
source "${UNISH}/plugins/${CURRENT_SHELL}.${CURRENT_SHELL}"

info 'Started Plugins.'


source "${UNISH}"/final.sh
