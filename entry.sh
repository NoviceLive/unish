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

export RCol='\e[0m' # Text Reset
export Bla='\e[0;30m' # Regular
export Red='\e[0;31m'
export Gre='\e[0;32m'
export Yel='\e[0;33m'
export Blu='\e[0;34m'
export Pur='\e[0;35m'
export Cya='\e[0;36m'
export Whi='\e[0;37m'
export BBla='\e[1;30m' # Bold
export BRed='\e[1;31m'
export BGre='\e[1;32m'
export BYel='\e[1;33m'
export BBlu='\e[1;34m'
export BPur='\e[1;35m'
export BCya='\e[1;36m'
export BWhi='\e[1;37m'
export UBla='\e[4;30m' # Underline
export URed='\e[4;31m'
export UGre='\e[4;32m'
export UYel='\e[4;33m'
export UBlu='\e[4;34m'
export UPur='\e[4;35m'
export UCya='\e[4;36m'
export UWhi='\e[4;37m'
export IBla='\e[0;90m' # High Intensity
export IRed='\e[0;91m'
export IGre='\e[0;92m'
export IYel='\e[0;93m'
export IBlu='\e[0;94m'
export IPur='\e[0;95m'
export ICya='\e[0;96m'
export IWhi='\e[0;97m'
export On_Bla='\e[40m' # Background
export On_Red='\e[41m'
export On_Gre='\e[42m'
export On_Yel='\e[43m'
export On_Blu='\e[44m'
export On_Pur='\e[45m'
export On_Cya='\e[46m'
export On_Whi='\e[47m'
export BIBla='\e[1;90m' # BoldHigh Intens
export BIRed='\e[1;91m'
export BIGre='\e[1;92m'
export BIYel='\e[1;93m'
export BIBlu='\e[1;94m'
export BIPur='\e[1;95m'
export BICya='\e[1;96m'
export BIWhi='\e[1;97m'
export On_IBla='\e[0;100m' # High Intensity Backgrounds
export On_IRed='\e[0;101m'
export On_IGre='\e[0;102m'
export On_IYel='\e[0;103m'
export On_IBlu='\e[0;104m'
export On_IPur='\e[0;105m'
export On_ICya='\e[0;106m'
export On_IWhi='\e[0;107m'


typeset -xr VERSION_STRING="${BICya}Unish-0.1.0${RCol}"


printf "Welcome to ${VERSION_STRING}\n\n"


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
if source "$UNISH"/lib/logging.sh; then
    info 'Started Logging System.'
else
    debug() {
        :
    }
    info() {
        :
    }
    warning() {
        :
    }
    error() {
        :
    }
    critical() {
        :
    }
fi


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


source "$UNISH"/lib/unish/"${CURRENT_SHELL}"."${CURRENT_SHELL}" &&
    info 'Reached Target Unish Environment.'


info 'Starting Unish Base...'

source "$UNISH"/lib/meta.sh


for one in math str media file repo; do
    source_if_exists "$UNISH"/lib/$one.sh
done


for one in repo smart file dev misc; do
    source_if_exists "$UNISH"/src/$one.sh
done

info 'Started Unish Base.'


export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus


# I often place binaries and symbolic links here.
export PATH=$PATH:$HOME/bin:$HOME/bin/lnk

# Here reside commands provided by Unish.
export PATH=$PATH:${UNISH}/cmd

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
