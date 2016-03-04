#!/usr/bin/env bash


pkgs=(
    'wqy-microhei'
    'firefox;flashplugin'
    'shadowsocks;privoxy;openssh'
    'git;mercurial;subversion'
    'emacs;vim'
    'tmux;python-virtualenvwrapper;xclip;wget'
    'virtualbox;virtualbox-guest-iso;virtualbox-host-dkms'
    'dkms;linux-headers'
    'qemu;qemu-arch-extra'
    'vlc;avidemux-cli;avidemux-gtk;audacity'
)


for one in ${pkgs[@]}; do
    sudo pacman -S --needed $(printf '%s' ${one} | tr ';' ' ')
done
