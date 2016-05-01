#!/usr/bin/env bash


comm <(pacman -Ssq haskell|sort) <(pacman -Ssq haskell|grep haskell|sort) "${@}"
