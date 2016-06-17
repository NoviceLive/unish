#!/usr/bin/env bash


sudo pacman -S $(pacman -Ssq noto-fonts|grep noto-fonts)
