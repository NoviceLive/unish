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


source "${UNISH}/lib/meta.sh"
source "${UNISH}/lib/repo.sh"


repo_home="${1:-${HOME}/repo}"
inactive_home="${repo_home}/inactive"

repos=($(lines_from_file dat/github.txt))
inactive=($(lines_from_file dat/inactive.txt))


clone_many 'git@github.com:' "${repo_home}" "${repos[@]}"
clone_many 'git@github.com:' "${inactive_home}" "${inactive[@]}"
