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


user_name='Gu Zhengxiong'
user_email='rectigu@gmail.com'


printf '[-] Configuring user.name: %s\n' "$user_name"
git config --global user.name "$user_name"

printf '[-] Configuring user.email: %s\n' "$user_email"
git config --global user.email "$user_email"


printf '[-] Disabling core.quotepath\n'
git config --global core.quotepath false

printf '[-] Configuring push.default: simple\n'
git config --global push.default simple


printf '[-] Configuring the aliases\n'
git config --global alias.h help
git config --global alias.i init
git config --global alias.s status
git config --global alias.a add
git config --global alias.t tag

git config --global alias.c commit
git config --global alias.cl clone
git config --global alias.f fetch
git config --global alias.p push
git config --global alias.pl pull

git config --global alias.l log
git config --global alias.bl blame
git config --global alias.rf reflog
git config --global alias.d diff

git config --global alias.r rm
git config --global alias.rem remote
git config --global alias.res reset

git config --global alias.b branch
git config --global alias.o checkout

git config --global alias.sm submodule
git config --global alias.st subtree

printf '[+] Done\n'
