#!/usr/bin/env bash


# Switch The Mirror Of RubyGems To The TaboBao-Hosted One
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


bad_source='https://rubygems.org/'
good_source='https://ruby.taobao.org/'


exists() {
    : "
Usage: exists <command>

Determine whether the command is available or not.
"
    command env which "$1" > /dev/null 2>&1
}


if exists gem; then
    printf "    current user: removing '%s'...\n" "$bad_source"
    gem sources -r "$bad_source"

    printf "    current user: adding '%s'...\n" "$good_source"
    gem sources -a "$good_source"
else
    printf '%s\n' '[!] gem unavailable'
fi
if exists bundle; then
    bundle config mirror."$bad_souce" "$good_source"
else
    printf '[!] %s\n' 'bundle unavailable'
fi


# printf "    sudo: removing '%s'...\n" "$bad_source"
# sudo gem sources -r "$bad_source"

# printf "    sudo: adding '%s'...\n" "$good_source"
# sudo gem sources -a "$good_source"

# sudo bundle config mirror."$bad_souce" "$good_source"
