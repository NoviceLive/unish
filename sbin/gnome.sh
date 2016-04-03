#!/usr/bin/env bash


pacman -S --needed xorg-server nvidia gnome &&
    pacman -R gvfs-smb &&
    systemctl enable gdm.service


# pacman -S --needed gnome-extra
# systemctl enable NetworkManager.service
