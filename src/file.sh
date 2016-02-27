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


# TODO: eq<hash>, rmdup[_rec], rmdups[_rec],
#       rm<hash>_rec, ls<hash>_rec.


_hash_types=(sha{1,224,256,383,512} md5)

_make_ls_hash_name() { stdout "ls${1}"; }
_make_rm_hash_name() { stdout "rm${1}"; }

for one in "${_hash_types[@]}"; do
    debug "Creating function ls${one}..."
    see_also=$(make_see_also "${one}" _make_ls_hash_name \
                             "${_hash_types[@]}")
    eval "
ls$one() {
    : \"
Usage: ls${one} <dir>

List the ${one}sum of files (but without filenames)
in the specified directory.

Generated checksums are meant to be consumed by rm${one}.

See Also: ${see_also}
\"
    _ls_hash_generic ${one}sum \"\${@}\"
}
"
    debug "Creating function rm${one}..."
    see_also=$(make_see_also "${one}" _make_rm_hash_name \
                             "${_hash_types[@]}")
    eval "
rm$one() {
    : \"
Usage: rm${one} <${one}sum> <${one}sum> ...

Remove the files with the specified ${one}sum.

See Also: ${see_also}
\"
    _rm_hash_generic ${one}sum \"\${@}\"
}
"
done


_ls_hash_generic() {
    local alg="${1}"
    local dir=${2:-${PWD}}
    find "${dir}" -maxdepth 1 -type f -exec \
         sh -c '"${2}" "${1}" | cut -d" " -f1' _ {} "${alg}" \; \
        | sort | tr '\n' ' '
    printf '\n'
}


_rm_hash_generic() {
    if [[ $# -lt 2 ]]; then
        error "One or more arguments of hashes required!"
        return 1
    fi
    local alg="${1}"
    local filename
    local current
    local wanted
    for filename in ./*; do
        current="$($alg "${filename}" | cut -d' ' -f1)"
        debug "${alg} of '${filename}' is ${current}."
        for wanted in "${@:2}"; do
            debug "Checking ${current} against ${wanted}..."
            if [[ "${current}" == "${wanted}" ]]; then
                info "Deleting ${filename}..."
                rm -f "${filename}"
            fi
        done
    done
}
