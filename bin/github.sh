#!/usr/bin/env bash


# Clone all public repositories after system reinstallation,
# after setting up Git and SSH.
#
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


repo_home="${1:-"${HOME}/repo"}"
inactive_home="${repo_home}/inactive"


repos=(
    NoviceLive/emacs.d.git # Will always be cloned manually
    NoviceLive/pat.git
    NoviceLive/shellcoding.git
    NoviceLive/unish.git # Will always be cloned manually
    NoviceLive/urlmark.git

    LibreCrops/about.git
    LibreCrops/bookmarks.git
    LibreCrops/lost-sdk.git
    LibreCrops/translation.git

    kbridge/cdef.git
)


inactive=(
    NoviceLive/grade-management-system.git
    NoviceLive/lsext.git
    NoviceLive/man2pdf.git
    NoviceLive/pdfextract.git
    NoviceLive/pdfmark.git
    NoviceLive/simple-typing-game.git
)


clone_many() {
    local base="${1}"
    local home="${2}"
    local many=("${@:3}")
    local name dest remote
    mkdir -p "${home}"
    for name in "${many[@]}"; do
        dest="${home}/$(basename "${name}")"
        if [[ -d "${dest}" ]]; then
            >&2 printf 'Already cloned: %s\n' "${name}"
        else
            remote="${base}${name}"
            >&2 printf 'Cloning %s\n' "${remote}"
            >&2 printf 'Dest: %s\n' "${dest}"
            git clone --recursive "${remote}" "${dest}"
        fi
    done
}


clone_many 'git@github.com:' "${repo_home}" "${repos[@]}"
clone_many 'git@github.com:' "${inactive_home}" "${inactive[@]}"
