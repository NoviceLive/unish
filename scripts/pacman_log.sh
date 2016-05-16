#!/usr/bin/env bash


grep -oP "(?<=\[PACMAN\] Running ').+(?=')" /var/log/pacman.log|less
