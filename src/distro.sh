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


# Saving keystrokes and memory of my mind.


unalias distup 2> /dev/null
distup() {
    if [[ -f '/etc/arch-release' ]]; then
        verbose sudo pacman --sync --refresh --sysupgrade "${@}" &&
            verbose sudo pacman --sync --clean --noconfirm
    elif [[ -f '/etc/debian_version' ]]; then
        verbose sudo apt-get update &&
            verbose apt-get dist-upgrade --assume-yes &&
            verbose apt-get autoremove --assume-yes &&
            verbose apt-get autoclean
    else
        # Handle it if you need.
        >&2 printf '%s\n' 'Unsupported Distribution!'
    fi
}


unalias pkgins 2> /dev/null
pkgins() {
    local package_names=(${@})

    if [[ -f '/etc/arch-release' ]]; then
        verbose sudo pacman --sync "${package_names[@]}"
    elif [[ -f '/etc/debian_version' ]]; then
        verbose sudo apt-get install "${package_names[@]}"
    else
        # Handle it if you need.
        >&2 printf '%s\n' 'Unsupported Distribution!'
    fi
}


unalias pkglog 2> /dev/null
pkglog () {
    if [[ -f '/var/log/pacman.log' ]]; then
        local regex="(?<=\[PACMAN\] Running ').+(?=')"
        local filename='/var/log/pacman.log'

        grep -oP "${regex}" "${filename}" | less
    elif [[ -f '/var/log/apt/history.log' ]]; then
        less '/var/log/apt/history.log'
    else
        # Handle it if you need.
        >&2 printf '%s\n' 'Unsupported Distribution!'
    fi
}


unalias owns 2> /dev/null
owns() {
    local filename=${1}

    if [[ -f '/etc/arch-release' ]]; then
        pacman --query --owns "${filename}"
    else
        # Handle it if you need.
        >&2 printf '%s\n' 'Unsupported Distribution!'
    fi
}


unalias provides 2> /dev/null
provides() {
    local filename=${1}

    if [[ -f '/etc/arch-release' ]]; then
        pkgfile --verbose "${filename}" "${@:2}"
    else
        # Handle it if you need.
        >&2 printf '%s\n' 'Unsupported Distribution!'
    fi
}


unalias lsbin 2> /dev/null
lsbin() {
    local package_name=${1}

    if [[ -f '/etc/arch-release' ]]; then
        pkgfile --list --binaries "${package_name}"
    else
        # Handle it if you need.
        >&2 printf '%s\n' 'Unsupported Distribution!'
    fi
}
