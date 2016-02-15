#!/usr/bin/env bash


#
# Switch The Mirror Of RubyGems To The TaboBao-Hosted One
#
# Copyright 2015 Gu Zhengxiong <rectigu@gmail.com>
#


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
