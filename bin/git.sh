#!/usr/bin/env bash


#
# Copyright 2015 Gu Zhengxiong <rectigu@gmail.com>
#


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
