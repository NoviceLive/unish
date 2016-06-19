#!/usr/bin/env bash


vboxmanage sharedfolder add 'Kali Linux x64' \
           --name public --hostpath /home/anon/public


vboxmanage modifyvm 'Kali Linux x64' \
           --clipboard bidirectional
