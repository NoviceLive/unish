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


ETC='etc'
PRIV='../../private/unish.hg/etc/ssh.conf'
CONF="${HOME}/.ssh/config"


mkdir -p ~/.ssh &&
    rm -f "${CONF}" &&
    touch "${CONF}" &&
    chmod 0600 "${CONF}"


if [[ -f ${PRIV} ]]; then
    printf 'Found Private Configuration!\n'
    cat ${ETC}/ssh.conf ${PRIV} >> ${CONF}
else
    printf 'No Private Configuration Used.\n'
    cat ${ETC}/ssh.conf >> ${CONF}
fi


printf 'Creating Symbolic Link for Git...\n'
ln -srf ${ETC}/.gitconfig ${HOME}/


printf 'Creating Symbolic Link for Mercurial...\n'
ln -srf ${ETC}/.hgrc ${HOME}/
