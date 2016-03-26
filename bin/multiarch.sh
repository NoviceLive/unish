#!/usr/bin/env bash


sudo dpkg --add-architecture i386 &&
    sudo apt-get update &&
    sudo apt-get install libc6:i386
