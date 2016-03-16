#!/usr/bin/env bash


pacman -S --needed xorg-server nvidia gnome gnome-extra &&
    pacman -R gvfs-smb &&
    systemctl enable gdm.service &&
    systemctl enable NetworkManager.service
