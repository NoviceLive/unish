# Copyright 2015-2016 Gu Zhengxiong <rectigu@gmail.com>
#
# This file is part of Unish.
#
# Unish is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License
# as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Unish is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Unish.  If not, see <http://www.gnu.org/licenses/>.


syncboard() {
    xclip -o | xclip -selection clipboard
}


clipboard() {
    xclip -o -selection clipboard
}


aurpkg() {
    : "
Download PKGBUILD from AUR and build them.

Usage: aurpkg <package> <package> ...

Examples:

$ aurpkg package-query
$ aurpkg yaourt
"
    local base='https://aur.archlinux.org/cgit/aur.git/snapshot'
    local name
    for name in "${@}"; do
        local url="${base}/${name}.tar.gz"
        info "Downloading ${url}..."
        wget "${url}" && tar -xzf "${name}.tar.gz" && \
            (builtin cd "${name}" && makepkg -si)
    done
}


# TODO: Hardcode.

mount7() {
    sudo mkdir -p /mnt/vdb /mnt/vdb2 || return 233
    sudo vdfuse \
         -f \
         "$HOME"/vm/76420151026/76420151026.vmdk \
         /mnt/vdb || return 233
    sudo mount /mnt/vdb/Partition2 /mnt/vdb2 || return 233
}


umount7() {
    sudo umount /mnt/vdb /mnt/vdb2 || return 233
}


lshp() {
    : "
Usage: lshp

Display proxy settings, i.e. 'http_proxy' and 'https_proxy'.
"
    stdout "http_proxy: ${http_proxy}"
    stdout "https_proxy: ${https_proxy}"
}


hpi() {
    sudo privoxy /etc/privoxy/config
}


hp() {
    : "
Usage: hp

Set proxies to http(s)://127.0.0.1:8118.
"
    export http_proxy=http://127.0.0.1:8118
    export https_proxy=https://127.0.0.1:8118
    lshp
}


hps() {
    : "
Usage: hps

Set proxies to http://127.0.0.1:8118. Stack requires this.
"
    export http_proxy=http://127.0.0.1:8118
    export https_proxy=http://127.0.0.1:8118
    lshp
}


unhp() {
    : "
Usage: unhp

Remove proxies.
"
    export http_proxy=
    export https_proxy=
    lshp
}


mkcd() {
    local name="${1}"
    if mkdir -p "${name}"; then
        builtin cd "${name}" || return 1
    else
        return 1
    fi
}


thosts() {
    if [[ -f /etc/hosts-on-proxy ]]; then
        sudo mv /etc/hosts /etc/hosts-no-proxy \
            && sudo mv /etc/hosts-on-proxy /etc/hosts
    else
        sudo mv /etc/hosts /etc/hosts-on-proxy \
            && sudo mv /etc/hosts-no-proxy /etc/hosts;
    fi
}


gbk2utf8() {
    local name="${1}"
    if iconv -f gbk -t utf8 "${name}" -o "${name}".utf8; then
        mv "${name}".utf8 "${name}"
    else
        command rm -f "${name}".utf8
    fi
}


utf8all() {
    find -type f -exec enca -x utf-8 -L 'chinese' {} \;
}


alias lt='tmux list-sessions'
alias ks='tmux kill-server'
alias lsc='count_items'

alias sudo='sudo '
alias ee='echo $?'


alias mksvg='dot -Tsvg -O *.gv'
alias mkpng='dot -Tpng -O *.gv'
alias mkjpg='dot -Tjpg -O *.gv'


for one in xz gzip gunzip bzip2 bunzip2; do
    eval "
${one}() {
    : \"
Usage: ${one} <options>

keep compressed files when decompressing.
\"
    ${one} --keep
}
"
done


alias 114='ping -c 4 114.114.114.114'
alias baidu='ping -c 4 baidu.com'


archisbest() {
    if exists rfkill; then
        rfkill unblock wifi
    fi
    sudo -b create_ap wlp3s0 enp4s0f2 ARCHISBEST ARCHISBEST
}


redhcp() {
    sudo systemctl restart dhcpcd@enp4s0f2.service
}


alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'


chinese() {
    grep '[\x{4e00}-\x{9fff}]' --perl-regexp \
         --recursive --only-matching --no-filename | wc -l
}


lsext_sh() {
    local dir="${1:-$PWD}"
    local name
    find "${dir}" -type f | while read -r filename; do
        name=$(basename "${filename}")
        [[ "${name}" = *.* ]] && printf '%s\n' "${name##*.}"
    done | sort | uniq -c | sort -nr
}


for name in gcc objdump; do
    eval "
64${name}() {
    x86_64-w64-mingw32-${name} \"\${@}\"
}


32${name}() {
    i686-w64-mingw32-${name} \"\${@}\"
}
"
done


alias CN='LC_ALL=zh_CN.UTF-8'


alias ..='cd ..'
alias ...='cd ../..'
alias .2='...'
alias ....='cd ../../..'
alias .3='....'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'


pkgbin() {
    pkgfile --search --binaries "${@}"
}


for one in 2 3; do
    eval "
ip${one}() {
    : \"
Quiet version of 'ipython${one}'.
\"
    ipython${one} --no-banner \"\${@}\"
}
"
done


for one in python3 gdb octave bc; do
    eval "
${one}() {
    : \"
Usage: ${one} <options>

Quiet version of '${one}'.
\"
    /usr/bin/env ${one} -q \"\${@}\"
}
"
done


alias pypy2='pypy'


alias Syu='sudo pacman -Syu'
alias Syy='sudo pacman -Syy'
alias Syyu='sudo pacman -Syyu'

alias Ss='pacman -Ss'

alias S='sudo pacman -S --noconfirm'
alias U='sudo pacman -U'

alias Si='pacman -Si'
alias Sii='pacman -Sii'

alias Qo='pacman -Qo'
alias Ql='pacman -Ql'
alias Qi='pacman -Qi'
alias Qii='pacman -Qii'

alias Sc='sudo pacman -Sc --noconfirm'

alias aS='yaourt -aS'
alias aSs='yaourt -aSs'
alias aSyu='yaourt -aSyu'
