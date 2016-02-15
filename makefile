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


ETC = etc
BIN = bin

default:
	make fish
	make zsh
	make bash
	make misc
	make xconf


fish:
	mkdir -p ~/.config/fish/
	ln -srf fish.fish ~/.config/fish/config.fish


zsh:
	ln -srf entry.sh ~/.zshrc


bash:
	ln -srf entry.sh ~/.bashrc


misc:
	ln -srf ${ETC}/tmux.conf ~/.tmux.conf

	ln -srf ${ETC}/hgrc.conf ~/.hgrc

	mkdir -p ~/.stack
	ln -srf ${ETC}/config.yaml ~/.stack/config.yaml

	mkdir -p ~/.ghc
	ln -srf ${ETC}/ghci.conf ~/.ghc/ghci.conf


xconf:
	${BIN}/git.sh
	${BIN}/ruby.sh
