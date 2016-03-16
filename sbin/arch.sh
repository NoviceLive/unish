#!/usr/bin/env bash


pkgs="${1}"


while read -r packags; do
    pacman -S --needed ${packags};
done < "${pkgs}"


unset pkgs
