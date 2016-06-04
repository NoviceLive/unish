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
	ln -srf entry.sh ~/.bashrc
	ln -srf entry.sh ~/.zshrc
	ln -srf ${ETC}/.tmux.conf ~/


termite:
	mkdir -p ~/.config/termite
	ln -srf ${ETC}/termite.conf ~/.config/termite/config


ibus:
	sudo cp ${ETC}/ibus.sh /etc/profile.d/ibus-env-vars.sh


xmonad:
	mkdir -p ~/.xmonad/
	ln -srf ${ETC}/xmonad.hs ~/.xmonad/


awesome:
	ln -srf ${ETC}/.Xresources ~/
	ln -srf ${ETC}/.xinitrc ~/
	mkdir -p ~/.config/awesome
	ln -srf ${ETC}/rc.lua ~/.config/awesome


scm:
	${BIN}/scm.sh


ghc:
	mkdir -p ~/.ghc
	ln -srf ${ETC}/ghci.conf ~/.ghc/ghci.conf
	mkdir -p ~/.stack
	ln -srf ${ETC}/config.yaml ~/.stack/config.yaml


gdb:
	ln -srf ${ETC}/.gdbinit ~/


fish:
	mkdir -p ~/.config/fish/
	ln -srf fish.fish ~/.config/fish/config.fish


# gtk:
# 	mkdir -p ~/.config/gtk-3.0
# 	ln -srf ${ETC}/gtk.conf ~/.config/gtk-3.0/settings.ini


# gnome:
# 	${BIN}/gnome.py


# arch:
# 	sudo ${CMD}/ins -bpacman ${DAT}/arch.txt


# aur:
# 	${CMD}/ins -byaourt ${DAT}/aur.txt


# pip3:
# 	sudo ${CMD}/ins -bpip3 ${DAT}/pip.txt ${DAT}/pip3.txt


# pip2:
# 	sudo ${CMD}/ins -bpip2 ${DAT}/pip.txt ${DAT}/pip2.txt
