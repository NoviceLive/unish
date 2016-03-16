#!/usr/bin/env bash


pacman -S --needed xorg-server nvidia gnome gnome-extra &&
    systemctl enable gdm.service &&
    systemctl enable NetworkManager.service
