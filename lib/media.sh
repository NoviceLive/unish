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


_media_formats=(mp3 mp4 webm mkv flv)

_make_sum_media_name() { stdout "sum${1}"; }
_make_cat_media_name() { stdout "cat${1}"; }

for one in "${_media_formats[@]}"; do
    debug "Creating function sum${one}..."
    see_also=$(make_see_also "${one}" _make_sum_media_name \
                             "${_media_formats[@]}")
    eval "
sum${one}() {
    : \"
Usage: sum${one} <dir> <dir> ...

Calculate total duration of ${one} files in the specified paths.

See Also: ${see_also}
\"
    _sum_media '${one}' \"\${@}\"
}
"
    see_also=$(make_see_also "${one}" _make_cat_media_name \
                             "${_media_formats[@]}")
    debug "Creating function cat${one}..."
    eval "
cat${one}() {
    : \"
Usage: cat${one} <dir>

Concatenate ${one} files in the specified directory.

See Also: ${see_also}
\"
    _cat_media_by_ffmpeg '${one}' \"\${@}\"
}
"
done


_sum_media() {
    local ext=${1}
    if [[ $# -gt 1 ]]; then
        paths=(${@:2})
    else
        paths=("$PWD")
    fi
    debug "${paths[@]}"
    local durations
    durations=$(for dir in "${paths[@]}"; do
                    for filename in "${dir}"/*.${ext}; do
                        _get_duration_by_ffprobe "${filename}"
                    done
                done)
    stdout "$(sec2min "$(add "${durations}")") Minutes"
}


_cat_media_by_ffmpeg() {
    local ext="${1}"
    local dir
    if [[ $# -gt 1 ]]; then
        dir="${2}"
    else
        dir="$PWD"
    fi
    local files
    files=("${dir}"/*."${ext}")
    echo ${#files}
    debug "Files before sort: ${files[*]}"
    # Warning: Words will split when using sort.
    files=("$(printf '%s\n' "${files[@]}" | sort --version-sort)")
    debug "Files after sort: ${files[*]}"
    local input
    input=$(printf '%s\n' "${files[@]}" | while read -r filename; do
                   stdout "file '${filename}'"
               done)
    info "Input given to ffmpeg: ${input[*]}"
    ffmpeg -f concat \
           -i <(stdout "${input[@]}") -c copy output."${ext}"
}


_get_duration_by_ffprobe() {
    filename="${1}"
    ffprobe -print_format csv=print_section=0 \
            -show_entries format=duration -loglevel quiet \
            "$filename"
}
