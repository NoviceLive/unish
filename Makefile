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
SBIN = sbin
CMD = cmd
DAT = dat


default:
	# Choose what you want and do not simply `make',
	# since it may break your existing configuration.
	# And because this Makefile isn't well-written :(.


shell:
	ln -srf ${ETC}/.xinitrc ~/
	ln -srf ${ETC}/.Xresources ~/
	make fish
	make zsh
	make bash
	make tmux


conf:
	make tmux
	make stack
	make ghci
	make gdb


xconf:
	make ruby
	make gnome


awesome:
	mkdir -p ~/.config/awesome
	ln -srf ${ETC}/rc.lua ~/.config/awesome


fish:
	mkdir -p ~/.config/fish/
	ln -srf fish.fish ~/.config/fish/config.fish


zsh:
	ln -srf entry.sh ~/.zshrc


bash:
	ln -srf entry.sh ~/.bashrc


tmux:
	ln -srf ${ETC}/.tmux.conf ~/



stack:
	mkdir -p ~/.stack
	ln -srf ${ETC}/config.yaml ~/.stack/config.yaml


ghci:
	mkdir -p ~/.ghc
	ln -srf ${ETC}/ghci.conf ~/.ghc/ghci.conf


gdb:
	ln -srf ${ETC}/.gdbinit ~/


gtk:
	mkdir -p ~/.config/gtk-3.0
	ln -srf ${ETC}/gtk.conf ~/.config/gtk-3.0/settings.ini


scm:
	${BIN}/scm.sh


ruby:
	echo Deprecated.
	# ${BIN}/ruby.sh


gnome:
	${BIN}/gnome.py


github:
	echo Deprecated.
	# ${BIN}/github.sh


arch:
	sudo ${CMD}/ins -bpacman ${DAT}/pkgs.txt


aur:
	${CMD}/ins -byaourt ${DAT}/aur.txt


pip3:
	sudo ${CMD}/ins -bpip3 ${DAT}/pip.txt ${DAT}/pip3.txt


pip2:
	sudo ${CMD}/ins -bpip2 ${DAT}/pip.txt ${DAT}/pip2.txt
