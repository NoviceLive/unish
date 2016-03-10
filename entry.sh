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


# Lazily use it for the time being.
# Credit:
# http://stackoverflow.com/questions/16843382/colored-shell-script-output-library


# Text Reset
RCol='\e[0m'

# Regular           Bold                Underline
Bla='\e[0;30m';     BBla='\e[1;30m';    UBla='\e[4;30m';
Red='\e[0;31m';     BRed='\e[1;31m';    URed='\e[4;31m';
Gre='\e[0;32m';     BGre='\e[1;32m';    UGre='\e[4;32m';
Yel='\e[0;33m';     BYel='\e[1;33m';    UYel='\e[4;33m';
Blu='\e[0;34m';     BBlu='\e[1;34m';    UBlu='\e[4;34m';
Pur='\e[0;35m';     BPur='\e[1;35m';    UPur='\e[4;35m';
Cya='\e[0;36m';     BCya='\e[1;36m';    UCya='\e[4;36m';
Whi='\e[0;37m';     BWhi='\e[1;37m';    UWhi='\e[4;37m';

# High Intensity      BoldHigh Intens     Background
IBla='\e[0;90m';    BIBla='\e[1;90m';   On_Bla='\e[40m';
IRed='\e[0;91m';    BIRed='\e[1;91m';   On_Red='\e[41m';
IGre='\e[0;92m';    BIGre='\e[1;92m';   On_Gre='\e[42m';
IYel='\e[0;93m';    BIYel='\e[1;93m';   On_Yel='\e[43m';
IBlu='\e[0;94m';    BIBlu='\e[1;94m';   On_Blu='\e[44m';
IPur='\e[0;95m';    BIPur='\e[1;95m';   On_Pur='\e[45m';
ICya='\e[0;96m';    BICya='\e[1;96m';   On_Cya='\e[46m';
IWhi='\e[0;97m';    BIWhi='\e[1;97m';   On_Whi='\e[47m';

# High Intensity Backgrounds
On_IBla='\e[0;100m';
On_IRed='\e[0;101m';
On_IGre='\e[0;102m';
On_IYel='\e[0;103m';
On_IBlu='\e[0;104m';
On_IPur='\e[0;105m';
On_ICya='\e[0;106m';
On_IWhi='\e[0;107m';


typeset -xr VERSION_STRING="${BICya}Unish-0.0.1${RCol}"


printf "This is ${VERSION_STRING}\n\n"


log_simple() {
    : "
Usage: log_simple <message>

Write a simple LOGGING message to STDERR.
"
    >&2 printf "${Cya}LOGGING${RCol} to ${BYel}STDERR${RCol}: ${*}\n"
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


for one in repo smart file dev misc; do
    source_if_exists "$UNISH"/src/$one.sh
done

info 'Started Unish Base.'


# I often place binaries and symbolic links here.
export PATH=$PATH:$HOME/bin:$HOME/bin/lnk

# Stack installs binaries here.
export PATH=$PATH:$HOME/.local/bin


export VISUAL='emacs -nw'
export EDITOR="$VISUAL"

export LESS='FXR'


ulimit -c unlimited


if [[ DISABLE_UNISH_PLUGINS -eq 1 ]]; then
    info 'Plugins disabled'
else
    info 'Starting Plugins...'
    source "${UNISH}/plugins/common.sh"
    source "${UNISH}/plugins/${CURRENT_SHELL}.${CURRENT_SHELL}"
    info 'Started Plugins.'
fi


source "${UNISH}"/final.sh
