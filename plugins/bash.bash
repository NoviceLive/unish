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


# TODO: The plugin system.


source_if_exists /usr/share/bash-completion/bash_completion


export BASH_IT="$HOME/refsrc/bash-it.git"
export BASH_IT_THEME='powerline'
source_if_exists "$BASH_IT"/bash_it.sh

for one in bash-it defaults git pip; do
    full="$BASH_IT"/completion/available/$one.completion.bash
    source_if_exists "$full"
done
for one in general stub; do
    full="$BASH_IT"/aliases/available/$one.aliases.bash
    source_if_exists "$full"
done


shopt -s autocd
