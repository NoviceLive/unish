#!/usr/bin/env bash


sudo pacman -S $(pacman -Ssq adobe-source-|grep adobe-source-)
