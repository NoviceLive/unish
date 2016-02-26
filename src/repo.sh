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


_hg_status_checker() {
    if [[ -d '.hg' ]]; then
        if [[ -n $(hg status) ]]; then
            pwd && hg status
        fi
        if [[ -n $(hg summary | grep '^phases') ]]; then
            pwd && hg summary
        fi
    fi
}


_git_status_checker() {
    if [[ -d '.git' ]]; then
        if [[ -n $(git status --porcelain) ]]; then
            pwd && git status
        fi
        if [[ -n $(git log --branches --not --remotes) ]]; then
            pwd && git log --branches --not --remotes
        fi
    fi
}


_make_ls_repo_name() { stdout "ls${1}"; }

_repo_types=(hg git)

for one in "${_repo_types[@]}"; do
    debug "Creating function ls${one}..."
    see_also=$(make_see_also "${one}" _make_ls_repo_name \
            "${_repo_types[@]}")
    eval "
ls${one}() {
    : \"
Usage: ls${one} <dir>

Check the status of ${one} repositories in the specified directory.

See Also: ${see_also}
\"
    local dir
    dir=\"\${1:-\$PWD}\"
    find \"\${dir}\" -maxdepth 1 -type d | while read filename; do
        debug \"Handling \${filename}\"
        (builtin cd \"\${filename}\" &&_${one}_status_checker)
    done
}
"
done


alias lg='lsgit'
alias lh='lshg'


lsrepo() {
    lshg "${1}"
    lsgit "${1}"
}


_git_repo_updater() {
    git pull --recurse-submodules
    if [[ -f .gitmodules ]]; then
        git submodule init && git submodule update
    fi
}


_hg_repo_updater() {
    hg pull && hg update
}


_svn_repo_updater() {
    svn update
}


_bzr_repo_updater() {
    bzr pull
}


_up_repo_generic() {
    local repos
    if [[ $# -gt 1 ]]; then
        repos=(${@:2})
    else
        repos=(*.$1)
    fi
    for one in "${repos[@]}"; do
        info "[${1}] Updating ${one}"
        (builtin cd "${one}" && _"${1}"_repo_updater)
    done
}


_repo_types=(hg git svn bzr)

_make_up_repo_name() { stdout "up${1}"; }

for one in "${_repo_types[@]}"; do
    debug "Creating function sum${one}..."
    see_also=$(make_see_also "${one}" _make_up_repo_name \
            "${_repo_types[@]}")
    eval "
up${one}() {
    : \"
Usage: up${one} <${one}-repo> <${one}-repo> ...

Update the specified ${one} repositories.

When used without parameters, it will update those
found at the current working directory.

See Also: ${see_also}
\"
    _up_repo_generic ${one} \"\$@\"
}
"
done


alias uprepo='upgit; uphg; upsvn; upbzr;'
