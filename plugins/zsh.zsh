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


_plugins_dir="/usr/share/zsh/plugins"


_plugin_name=zsh-syntax-highlighting
_plugin_entry="$_plugins_dir/$_plugin_name/$_plugin_name.zsh"
source_if_exists "$_plugin_entry"

_plugin_name=zsh-history-substring-search
_plugin_entry="$_plugins_dir/$_plugin_name/$_plugin_name.zsh"
source_if_exists "$_plugin_entry" \
    && bindkey -M emacs '^P' history-substring-search-up \
    && bindkey -M emacs '^N' history-substring-search-down

# _plugin_name=zsh-autosuggestions
# _plugin_entry="$_plugins_dir/$_plugin_name/autosuggestions.zsh"
# zle-line-init() {
#     zle autosuggest-start
# }
# source_if_exists "$_plugin_entry" && zle -N zle-line-init


export ZSH="/usr/share/oh-my-zsh"
export ZSH_THEME=terminalparty
export DISABLE_AUTO_UPDATE=true
export plugins=(mercurial git)
source_if_exists "$ZSH/oh-my-zsh.sh"
