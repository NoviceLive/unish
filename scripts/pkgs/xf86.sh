#!/usr/bin/env bash


sudo pacman -S $(pacman -Ssq xf86-|grep xf86-)
