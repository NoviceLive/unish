#!/usr/bin/env bash


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


set_one() {
    local path=${1}
    local item=${2}
    local args=${3}
    >&2 printf 'Setting %s %s to %s\n' "${path}" "${item}" "${args}"
    >&2 printf 'Original Value: %s\n' \
        "$(gsettings get "${path}" "${item}")"
    gsettings set "${path}" "${item}" "${args}"
    >&2 printf 'Current Value: %s\n' \
        "$(gsettings get "${path}" "${item}")"
    >&2 printf '%s\n' 'Done'
}


# I prefer the default of Dolphin, the KDE file manager.
set_one org.gnome.nautilus.preferences click-policy 'single'


set_one org.gnome.desktop.media-handling automount false
